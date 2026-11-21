#!/usr/bin/env python3
"""Optimistic resource bounds for the Gaussian blur stage on the project's hardware
(Xeon Silver 4208, Cascade Lake). Python 3.6+; numpy is optional (accuracy columns only).

What the numbers are: each candidate implementation is written down as an explicit loop schedule (see
--schedule): which loads, arithmetic, shuffles and stores execute per output pixel, how many independent
accumulator chains are in flight, and how many vector registers are live. From that the model computes lower
bounds on cycles per output pixel from

    execution ports (Hall's bound over ports 0/1/5/6, as scripts/port_model.py), 4-wide issue, 2 loads/cycle
    (a cache-line-split load costs 2), 1 store/cycle, and the loop-carried dependency chains,

and lower bounds on time from the bytes each phase moves through L2, L3 and DRAM (project-measured bandwidths).
They are NOT achieved speeds: no schedule was compiled or timed, branch/loop startup per row, borders, 4K
aliasing, store forwarding and prefetcher behaviour are not modeled. Treat them as ceilings to compare
candidates and to check measurements against.

Sequencing: the passes of a candidate run as separate loops one after another (a fused loop would need its
passes' coefficient and accumulator registers live at the same time; that overlap is not assumed). Compute time of
the passes in one streaming group adds; groups separated by a full-image barrier (the "2pass" candidates) are
bounded one after another, T = sum_i max(T_compute_i, T_memory_i).

Usage:
  python3 scripts/gaussian_peak_model.py
  python3 scripts/gaussian_peak_model.py --configs 1.4:5 2:9 1.5:3:5:15d --sizes 640x480 3840x2160
  python3 scripts/gaussian_peak_model.py --schedule --configs 1.4:5   # registers, chains, instruction templates
  python3 scripts/gaussian_peak_model.py --scope node --ghz 2.4       # 2 sockets, 16 cores
  python3 scripts/gaussian_peak_model.py --detail                     # uop counts per 32 pixels

Config syntax:  SIGMA:K  |  SX:SY:KX:KY   (append d for disk/ellipse support, not separable)
"""
import argparse
import csv
import itertools
import math
import os
import statistics

KB, MB = 1024, 1024 * 1024
HERE = os.path.dirname(os.path.abspath(__file__))

# ---------------------------------------------------------------------------------------------------
# Hardware: Xeon Silver 4208 (8 cores, 11 MB L3, 3.2 GHz max turbo). The test system ece017-024 has two of them
# (16 cores, 32 threads). Capacities and bandwidths are the project's (roofs.py, roofline/bw*.csv).
# ---------------------------------------------------------------------------------------------------
CAPACITY = {  # level an image of a given footprint is assumed to live in: an explicit APPROXIMATION
    'one_core': [('L1', 32 * KB), ('L2', 1 * MB), ('L3', 11 * MB), ('DRAM', float('inf'))],
    'node': [('L1', 16 * 32 * KB), ('L2', 16 * MB), ('L3', 22 * MB), ('DRAM', float('inf'))],
}
CORES = {'one_core': 1, 'node': 16}          # physical cores; SMT adds no vector ports
L1_BYTES = 32 * KB
L2_BYTES = 1 * MB
# Measured streaming bandwidth, GB/s, counting write-allocate traffic beyond L1 (bytes moved = reads + writes +
# write-allocate reads). 'node' = the 32-thread run across both sockets; it assumes each socket works on its own
# NUMA-local half of the image.
MEASURED_GBPS = {
    'one_core': {'L1': 194.1, 'L2': 134.7, 'L3': 33.4, 'DRAM': 18.0},
    'node': {'L1': 2194.4, 'L2': 1325.9, 'L3': 289.4, 'DRAM': 64.7},
}
BW_SCOPE = {'one_core': 'one_core', 'node': 'all_threads'}
SPEC_DRAM_GBPS = {'one_core': 38.4, 'node': 76.8}   # 2 of 6 channels populated per socket, DDR4-2400

# Cascade Lake 256-bit uops: allowed ports (uops.info, Skylake-X forms). EVEX forms (needed for ymm16-31 and for
# the BW/VL integer instructions on ymm16+) are assumed to have identical uop counts and ports.
UOP = {
    'fma': '01', 'fmul': '01', 'fadd': '01', 'cvtdq2ps': '01', 'cvtps2dq': '01',
    'pmulhrsw': '01', 'psllw': '01', 'paddw': '015', 'pavgb': '01',
    'pmovzx': '5', 'packusdw': '5', 'packuswb': '5', 'permd': '5', 'permq': '5',
    'scalar_add': '0156', 'branch': '06',
}
LAT = {'fma': 4, 'fmul': 4, 'fadd': 4, 'pmulhrsw': 5, 'paddw': 1, 'pavgb': 1}   # cycles, for loop-carried chains
ISSUE_WIDTH = 4        # fused-domain slots per cycle
LOAD_PORTS = 2         # 256-bit loads per cycle (a cache-line-split load uses a port twice)
STORE_PER_CYCLE = 1    # 256-bit stores per cycle (store address on port 7: base+displacement addressing)
ALU_PORTS = '0156'
# Independent accumulator chains the schedule tries to keep: 8 for FMA (4-cycle latency x 2 FMA ports),
# 4 for the integer pipeline (the chained op is a 1-cycle vpaddw; the 5-cycle vpmulhrsw products are not chained).
TARGET_CHAINS = {'f32': 8, 'u16': 4}
VEC = {'f32': 8, 'u16': 16, 'u8': 32}
ELEM = {'f32': 4, 'u16': 2, 'u8': 1}
MUL = {'f32': 'fma', 'u16': 'pmulhrsw'}


# ---------------------------------------------------------------------------------------------------
# Resource accounting
# ---------------------------------------------------------------------------------------------------
class Res(object):
    """Resource use of a code sequence (per output pixel once scaled)."""

    def __init__(self):
        self.alu = {}          # port-set string -> uops
        self.slots = 0.0       # fused-domain issue/retire slots
        self.loads = 0.0       # load uops
        self.split = 0.0       # extra load-port cycles from 64 B cache-line-split loads
        self.stores = 0.0      # 256-bit stores
        self.ops = {}

    def _count(self, name, n):
        self.ops[name] = self.ops.get(name, 0.0) + n

    def op(self, name, n=1.0, mem=False, shifted=False):
        """n uops of an ALU instruction. mem: one source is a micro-fused load (1 slot). shifted: that load is
        element-shifted (unaligned), so half of them cross a 64 B line."""
        ports = UOP[name]
        self.alu[ports] = self.alu.get(ports, 0.0) + n
        self.slots += n
        self._count(name + ('+ld' if mem else ''), n)
        if mem:
            self.loads += n
            if shifted:
                self.split += 0.5 * n
        return self

    def load(self, n=1.0, shifted=False, what='load'):
        self.loads += n
        self.slots += n
        if shifted:
            self.split += 0.5 * n
        self._count(what, n)
        return self

    def store(self, n=1.0):
        self.stores += n
        self.slots += n
        self._count('store', n)
        return self

    def loop(self, ptr_adds):
        """Loop overhead of one iteration: pointer increments and the fused cmp+branch."""
        self.op('scalar_add', ptr_adds)
        self.op('branch', 1)
        return self

    def scaled(self, f):
        r = Res()
        r.alu = dict((k, v * f) for k, v in self.alu.items())
        r.slots, r.loads, r.split, r.stores = self.slots * f, self.loads * f, self.split * f, self.stores * f
        r.ops = dict((k, v * f) for k, v in self.ops.items())
        return r

    def add(self, other, w=1.0):
        for k, v in other.alu.items():
            self.alu[k] = self.alu.get(k, 0.0) + v * w
        self.slots += other.slots * w
        self.loads += other.loads * w
        self.split += other.split * w
        self.stores += other.stores * w
        for k, v in other.ops.items():
            self.ops[k] = self.ops.get(k, 0.0) + v * w
        return self


def hall(alu):
    """Hall's bound over every set S of ALU ports: uops that can only use S need count/|S| cycles."""
    best, best_set = 0.0, ''
    for k in range(1, len(ALU_PORTS) + 1):
        for s in itertools.combinations(ALU_PORTS, k):
            n = sum(v for ports, v in alu.items() if set(ports) <= set(s))
            if n / k > best + 1e-12:
                best, best_set = n / k, ''.join(s)
    return best, best_set


def bounds(res, dep=0.0):
    """Lower bounds in cycles per pixel: ports, issue, loads, stores, dependency chains. Returns (name, cyc, all)."""
    alu, ports = hall(res.alu)
    b = [
        ('ALU p%s' % ports, alu),
        ('issue', res.slots / ISSUE_WIDTH),
        ('load ports', (res.loads + res.split) / LOAD_PORTS),
        ('store', res.stores / STORE_PER_CYCLE),
        ('dependency', dep),
    ]
    name, cyc = max(b, key=lambda x: x[1])
    return name, cyc, dict(b)


class Pass(object):
    """One loop (phase) of a candidate: per-output-pixel resources, dependency bound, registers, schedule text."""

    def __init__(self, name, res, dep=0.0, live=None, sched=None, rows=1):
        self.name, self.res, self.dep, self.live, self.sched, self.rows = name, res, dep, live or {}, sched or [], rows
        self.bound, self.cyc, self.parts = bounds(res, dep)


# ---------------------------------------------------------------------------------------------------
# Configurations
# ---------------------------------------------------------------------------------------------------
class Config(object):
    def __init__(self, sx, sy, kx, ky, disk=False):
        self.sx, self.sy, self.kx, self.ky, self.disk = sx, sy, kx, ky, disk
        self.rx, self.ry = kx // 2, ky // 2
        taps = []
        for dy in range(-self.ry, self.ry + 1):
            for dx in range(-self.rx, self.rx + 1):
                if disk and (dx / max(self.rx, 1.0)) ** 2 + (dy / max(self.ry, 1.0)) ** 2 > 1.0 + 1e-9:
                    continue
                taps.append((dy, dx))
        self.taps = taps

    @property
    def separable(self):
        return not self.disk

    @property
    def label(self):
        s = ('%g:%d' % (self.sx, self.kx)) if (self.sx == self.sy and self.kx == self.ky) \
            else '%g:%g:%d:%d' % (self.sx, self.sy, self.kx, self.ky)
        return s + ('d' if self.disk else '')

    def desc(self):
        shape = 'disk %d taps' % len(self.taps) if self.disk else 'rect'
        return 'sigma %g/%g, %dx%d (%s)' % (self.sx, self.sy, self.kx, self.ky, shape)

    def distinct_2d(self):
        """Distinct coefficient values of the symmetric 2D kernel (equal taps share one register)."""
        if self.sx == self.sy and self.kx == self.ky:
            return len(set(tuple(sorted((abs(dy), abs(dx)))) for dy, dx in self.taps))
        return len(set((abs(dy), abs(dx)) for dy, dx in self.taps))

    @staticmethod
    def gauss1d(sigma, r):
        w = [math.exp(-(i * i) / (2.0 * sigma * sigma)) for i in range(-r, r + 1)]
        s = sum(w)
        return [v / s for v in w]

    def weights2d(self):
        """(wy, wx, W2): 1D weights and the normalized 2D weight matrix (zero outside support)."""
        wx, wy = self.gauss1d(self.sx, self.rx), self.gauss1d(self.sy, self.ry)
        W2 = [[0.0] * self.kx for _ in range(self.ky)]
        tot = 0.0
        for dy, dx in self.taps:
            v = wy[dy + self.ry] * wx[dx + self.rx]
            W2[dy + self.ry][dx + self.rx] = v
            tot += v
        return wy, wx, [[v / tot for v in row] for row in W2]


def parse_config(text):
    disk = text.endswith('d')
    if disk:
        text = text[:-1]
    p = text.split(':')
    if len(p) == 2:
        c = Config(float(p[0]), float(p[0]), int(p[1]), int(p[1]), disk)
    elif len(p) == 4:
        c = Config(float(p[0]), float(p[1]), int(p[2]), int(p[3]), disk)
    else:
        raise ValueError('bad config %r' % text)
    if c.kx % 2 == 0 or c.ky % 2 == 0:
        raise ValueError('kernel sizes must be odd: %r' % text)
    return c


# ---------------------------------------------------------------------------------------------------
# Schedules. Numeric formats:
#   f32: 8 pixels/ymm, vfmadd231ps; result vcvtps2dq (round to nearest even) and packed with saturation.
#   u16: 16 pixels/ymm, fixed point with vpmulhrsw (signed 16-bit rounding multiply-high):
#        non-symmetric: data Q7 (x << 7), tap = (v*c15 + 2^14) >> 15, sums stay in Q7 (<= 32640)
#        symmetric:     data Q6 (x << 6) so pair sums x[-j] + x[+j] (<= 32640) stay signed-16-safe
#        final round to uint8: one vpmulhrsw with 2^(15-q).
# ---------------------------------------------------------------------------------------------------
def widen_pass(kind, name='widen'):
    r = Res()
    r.op('pmovzx', 1, mem=True)          # vpmovzxbd / vpmovzxbw from memory: p5 + load
    r.op('cvtdq2ps' if kind == 'f32' else 'psllw', 1)
    r.store(1)
    out = r.scaled(1.0 / VEC[kind])
    out.add(Res().loop(2).scaled(1.0 / (VEC[kind] * 4)))      # 4 vectors per iteration
    sched = ['%s: vpmovzx%s ymm,[u8 src]; %s; vmovups [row],ymm   (x4 per iteration)'
             % (name, 'bd' if kind == 'f32' else 'bw', 'vcvtdq2ps' if kind == 'f32' else 'vpsllw ymm,ymm,7 (6 if sym)')]
    return Pass(name, out, 0.0, dict(total=3), sched)


def final_vec(kind):
    """Round and narrow one result vector; pack ops and the uint8 store are shared by 4 (f32) or 2 (u16) vectors."""
    r = Res()
    if kind == 'f32':
        r.op('cvtps2dq', 1)
        r.op('packusdw', 0.5).op('packuswb', 0.25).op('permd', 0.25)
        r.store(0.25)
    else:
        r.op('pmulhrsw', 1)
        r.op('packuswb', 0.5).op('permq', 0.5)
        r.store(0.5)
    return r


def allocate(kind, regs, ncoef, R, src_per_col, temps):
    """Register/chain plans. C = columns interleaved, chains = R*C accumulators. Option A holds all coefficients in
    registers; option B holds 2 and reloads each coefficient (one load) once per group of R*C outputs."""
    T = TARGET_CHAINS[kind]
    plans = []
    for held in (True, False):
        for C in range(-(-T // R), 0, -1):
            chains = R * C
            coef_regs = ncoef if held else 2
            live = coef_regs + chains + C * src_per_col + temps
            if live <= regs:
                plans.append(dict(held=held, C=C, chains=chains, live=live, coef=coef_regs,
                                  src=C * src_per_col, temps=temps))
                break
    return plans


def sum_pass(kind, name, regs, R, ring_store, final, ncoef, taps=None, K=None, vertical=False, sym=False):
    """Weighted-sum pass producing one output row per output vector, R rows per group.
    dense (taps given, any 2D support) or sym (1D symmetric of length K). Chooses the better register plan."""
    f32 = kind == 'f32'
    best = None
    for plan in allocate(kind, regs, ncoef, R, 1 if R > 1 else 0, 2):
        r = Res()                     # per ONE output vector
        if not sym:
            m = len(taps)
            if R == 1:
                for i, (dy, dx) in enumerate(taps):
                    r.op('fmul' if (f32 and i == 0) else MUL[kind], 1, mem=True, shifted=dx != 0)
                    if not f32 and i:
                        r.op('paddw', 1)
            else:
                uniq = set((dy + i, dx) for dy, dx in taps for i in range(R))
                for (_, dx) in uniq:
                    r.load(1.0 / R, shifted=dx != 0, what='src load')
                if f32:
                    r.op('fmul', 1).op('fma', m - 1)
                else:
                    r.op('pmulhrsw', m).op('paddw', m - 1)
            lat = (m * LAT['fma']) if f32 else (LAT['pmulhrsw'] + (m - 1) * LAT['paddw'])
            n_nominal = m
        else:
            rad = K // 2
            shifted = not vertical
            if R == 1 or not vertical:
                r.op('fmul' if f32 else 'pmulhrsw', 1, mem=True)
                for j in range(1, rad + 1):
                    r.load(1, shifted=shifted, what='src load')
                    r.op('fadd' if f32 else 'paddw', 1, mem=True, shifted=shifted)
                    r.op('fma' if f32 else 'pmulhrsw', 1)
                    if not f32:
                        r.op('paddw', 1)
            else:
                r.load((R + K - 1.0) / R, what='src load')
                r.op('fmul' if f32 else 'pmulhrsw', 1)
                r.op('fadd' if f32 else 'paddw', rad)
                r.op('fma' if f32 else 'pmulhrsw', rad)
                if not f32:
                    r.op('paddw', rad)
            lat = (LAT['fma'] * (rad + 1)) if f32 else (LAT['pmulhrsw'] + rad * LAT['paddw'])
            n_nominal = rad + 1
        if not plan['held']:
            r.load(float(ncoef) / plan['chains'], what='coef load')
        if ring_store:
            r.store(1)
        if final:
            r.add(final_vec(kind))
        px = VEC[kind]
        res = r.scaled(1.0 / px)
        span = (max(d[0] for d in taps) - min(d[0] for d in taps) + 1) if taps else (K if vertical else 1)
        ptr = (span + R - 1) + 1          # one pointer per live source row (non-indexed addressing) + destination
        res.add(Res().loop(ptr).scaled(1.0 / (px * plan['chains'])))
        dep = float(lat) / plan['chains'] / px
        p = Pass(name, res, dep, dict(plan, ncoef=ncoef), rows=R)
        if best is None or p.cyc < best.cyc - 1e-12:
            best = p
    best.sched = sched_text(kind, name, taps, K, vertical, sym, R, best.live)
    return best


def sched_text(kind, name, taps, K, vertical, sym, R, live):
    f32 = kind == 'f32'
    C, ch = live['C'], live['chains']
    mulop, addop = ('vfmadd231ps', 'vaddps') if f32 else ('vpmulhrsw+vpaddw', 'vpaddw')
    if taps and all(dx == 0 for _, dx in taps):
        vertical = True
    where = '2D, ring rows' if (taps and any(dx for _, dx in taps) and any(dy for dy, _ in taps)) else \
        ('vertical over ring rows' if vertical else 'horizontal, shifted loads')
    n = len(taps) if taps else K
    out = ['%s (%s): %d output rows x %d columns interleaved = %d independent accumulator chains' % (name, where, R, C, ch)]
    if sym:
        out.append('   centre: %s; per pair j: t=%s [-j],[+j]; acc=%s t,c_j  (pair add before the multiply)'
                   % ('vmulps' if f32 else 'vpmulhrsw', addop, mulop))
    else:
        out.append('   per tap (%d): acc = %s coef_t, src%s' % (n, mulop, ' (mem operand)' if R == 1 else ' (reg, loaded once per source row, reused by %d outputs)' % R))
    out.append('   registers: %d coefficients %s + %d accumulators + %d source + %d temps = %d'
               % (live['coef'], '(all held)' if live['held'] else '(2 working; reloaded with %s)' %
                  ('vbroadcastss ymm,[m32]' if f32 else 'vmovdqu ymm,[expanded table]'),
                  ch, live['src'], live['temps'], live['live']))
    return out


def avg_stage_pass(name, vertical, chains=4):
    """One [1 2 1]/4 stage built from two vpavgb on u8 data, 32 pixels per ymm:  t = avg(avg(x[-1], x[+1]), x[0]).
    Each stage reads u8 from memory and writes u8 (a stage ring row or the output); no widening or packing."""
    r = Res()
    r.load(1, shifted=not vertical, what='src load')
    r.op('pavgb', 1, mem=True, shifted=not vertical)
    r.op('pavgb', 1, mem=True)
    r.store(1)
    px = VEC['u8']
    res = r.scaled(1.0 / px)
    res.add(Res().loop(4 if vertical else 2).scaled(1.0 / (px * chains)))
    dep = 2.0 * LAT['pavgb'] / chains / px
    live = dict(live=chains + 1, held=True, coef=0, chains=chains, src=0, temps=1, C=chains)
    sched = ['%s (%s): %d vectors interleaved; t=vmovdqu [x-1]; t=vpavgb t,[x+1]; t=vpavgb t,[x]; vmovdqu [dst],t'
             % (name, 'rows y-1,y,y+1' if vertical else 'shifted loads', chains)]
    if vertical:
        sched[0] = sched[0].replace('[x-1]', '[row y-1]').replace('[x+1]', '[row y+1]').replace('[x]', '[row y]')
    return Pass(name, res, dep, live, sched)


def binomial_candidates(cfg):
    """Cascaded [1 2 1]/4 averages: N stages per axis = binomial (2N+1)-tap, variance N/2. This is a different
    filter from the sampled Gaussian: reported with its error against the requested kernel. Stage counts are
    chosen to match the truncated kernel's variance; (1,1) is the plain 3x3 binomial."""
    def nstages(sigma, r):
        w = cfg.gauss1d(sigma, r)
        var = sum(w[i + r] * i * i for i in range(-r, r + 1))
        return max(1, int(round(2.0 * var)))
    nx, ny = nstages(cfg.sx, cfg.rx), nstages(cfg.sy, cfg.ry)
    out = []
    for (a, b) in sorted(set([(nx, ny), (1, 1)])):
        hs = [avg_stage_pass('H', False) for _ in range(a)]
        vs = [avg_stage_pass('V', True) for _ in range(b)]
        out.append(dict(R=1, name='binom_avg(%d,%d)' % (a, b), kind='u8', groups=[hs + vs], ring_rows=3 * b + 2, s_t=1,
                        buffered=True, acc_key='binom', vrows=1, approx=True, kx_eff=2 * a + 1, nstages=(a, b)))
    return out


def per_group_cycles(passes, halo, halo_names):
    return sum(p.cyc * (halo if p.name in halo_names else 1.0) for p in passes)


def build_candidates(cfg, kind_list, regs, R):
    """Candidates for one config at V-block R. Each candidate: groups = list of lists of Pass."""
    cands = []
    for kind in kind_list:
        if kind == 'u8':
            if cfg.separable:
                cands.extend(binomial_candidates(cfg))
            continue
        s_t = ELEM[kind]
        wid = widen_pass(kind)
        dense_nc = cfg.distinct_2d()
        d = sum_pass(kind, 'direct', regs, R, False, True, dense_nc, taps=cfg.taps)
        cands.append(dict(R=d.rows, name='direct2d_%s' % kind, kind=kind, groups=[[wid, d]], ring_rows=cfg.ky + d.rows - 1,
                          s_t=s_t, buffered=True, acc_key='direct', vrows=d.rows))
        if not cfg.separable:
            continue
        for sym in (False, True):
            if sym:
                h = sum_pass(kind, 'H', regs, 1, True, False, cfg.rx + 1, K=cfg.kx, vertical=False, sym=True)
                v = sum_pass(kind, 'V', regs, R, False, True, cfg.ry + 1, K=cfg.ky, vertical=True, sym=True)
            else:
                h = sum_pass(kind, 'H', regs, 1, True, False, cfg.rx + 1,
                             taps=[(0, dx) for dx in range(-cfg.rx, cfg.rx + 1)])
                v = sum_pass(kind, 'V', regs, R, False, True, cfg.ry + 1,
                             taps=[(dy, 0) for dy in range(-cfg.ry, cfg.ry + 1)])
            nm = 'sep_%s%s' % (kind, '_sym' if sym else '')
            common = dict(R=v.rows, kind=kind, s_t=s_t, sym=sym, acc_key='sep_sym' if sym else 'sep', vrows=v.rows)
            cands.append(dict(common, name=nm + '_ring', groups=[[wid, h, v]], ring_rows=cfg.ky + v.rows - 1, buffered=True))
            cands.append(dict(common, name=nm + '_2pass', groups=[[wid, h], [v]], ring_rows=0, buffered=False))
    return cands


# ---------------------------------------------------------------------------------------------------
# Memory and time. Residency by footprint is an explicit approximation.
# ---------------------------------------------------------------------------------------------------
def level_of(scope, footprint):
    return next(n for n, cap in CAPACITY[scope] if footprint <= cap)


def tile_and_halo(cand, cfg, W, l1_frac):
    """Largest column tile (multiple of 32) whose ring + u8 strips + one temp row fit l1_frac of L1."""
    if not cand['buffered']:
        return W, 1.0
    per_col = cand['ring_rows'] * cand['s_t'] + 1 + 1 + cand['s_t']
    tx = max(32, min(W, int((l1_frac * L1_BYTES) // per_col) // 32 * 32))
    return tx, (1.0 if tx >= W else (tx + cand.get('kx_eff', cfg.kx) - 1.0) / tx)


def mem_time(level, b_l2, b_stream, bw):
    """Seconds per pixel from each interface: L1<->L2 carries every L1 miss (b_l2); data resident in L3 or DRAM
    also crosses the L3 interface; DRAM-resident data crosses the DRAM interface."""
    t = {}
    if level != 'L1':
        t['L2'] = b_l2 / (bw['L2'] * 1e9)
        if level in ('L3', 'DRAM'):
            t['L3'] = b_stream / (bw['L3'] * 1e9)
        if level == 'DRAM':
            t['DRAM'] = b_stream / (bw['DRAM'] * 1e9)
    return t


def evaluate(cand, cfg, W, H, scope, ghz, l1_frac, bw):
    n = CORES[scope]
    s_t = cand['s_t']
    tx, halo = tile_and_halo(cand, cfg, W, l1_frac)
    fc = n * ghz * 1e9
    total_t, core_cyc, mem_t_total, limits = 0.0, 0.0, 0.0, []
    levels = []
    mem_detail = {}
    for gi, group in enumerate(cand['groups']):
        names = set(['widen', 'H']) if cand['buffered'] and halo > 1.0 else set()
        cyc = per_group_cycles(group, halo, names)
        t_c = cyc / fc
        if cand['buffered']:
            footprint = W * H * 2
            b_stream = 1 * halo + 2          # input (+halo columns) read; output written with write-allocate
            b_l2 = b_stream
        elif gi == 0:                       # widen + H over the whole image: read u8, write intermediate (+RFO)
            footprint = W * H * (1 + s_t)
            b_stream = 1 + 2 * s_t
            b_l2 = b_stream
        else:                               # V over the whole image: read intermediate, write u8 (+RFO)
            footprint = W * H * (s_t + 1)
            b_stream = s_t + 2
            b_l2 = b_stream
            rows_live = cand['vrows'] + cfg.ky - 1
            reuse = rows_live * W * s_t       # rows the next row-group re-reads, plus the new ones
            extra = s_t * (cfg.ky - 1.0) / cand['vrows']
            if reuse > l1_frac * L1_BYTES:    # overlap rows come back from L2 instead of L1
                b_l2 += extra
            if reuse > 0.75 * L2_BYTES:       # and from L3/DRAM if they do not even stay in L2
                b_stream += extra
        lvl = level_of(scope, footprint)
        mt = mem_time(lvl, b_l2, b_stream, bw)
        t_m = max(mt.values()) if mt else 0.0
        mem_limit = max(mt, key=lambda k: mt[k]) if mt else ''
        total_t += max(t_c, t_m)
        core_cyc += cyc
        mem_t_total += t_m
        levels.append(lvl)
        limits.append(('core' if t_c >= t_m else mem_limit))
        mem_detail[gi] = dict(level=lvl, b_l2=b_l2, b_stream=b_stream, t=mt)
    r = 1.0 / total_t
    return dict(cyc=core_cyc, r=r, r_core=fc / core_cyc, r_mem=(1.0 / mem_t_total if mem_t_total else float('inf')),
                levels=levels, limits=limits, tx=tx, halo=halo, mem=mem_detail,
                bounds=[[(p.name, p.bound, p.cyc, p.dep) for p in g] for g in cand['groups']])


# ---------------------------------------------------------------------------------------------------
# Numerical behaviour of the modeled schedules (numpy). References:
#   f64   exact 2D Gaussian in float64, round half up
#   scalar  the project's canny_scalar blur: float32 weights from expf, per-tap rounded multiply then add in
#           row-major tap order (no FMA: baseline x86-64), floor(v + 0.5f)
# Float32 schedules use real FMA semantics (single rounding), the schedule's tap order, pair-add-then-FMA for
# the symmetric one, and round-to-nearest-even in vcvtps2dq. Fixed-point schedules follow vpmulhrsw exactly.
# ---------------------------------------------------------------------------------------------------
def make_images(np, size):
    rng = np.random.RandomState(18645)
    noise = rng.randint(0, 256, size=(size, size)).astype(np.uint8)
    ramp = np.add.outer(np.arange(size), np.arange(size)) * 255.0 / (2 * size - 2)
    smooth = np.clip(ramp + rng.randint(-3, 4, size=(size, size)), 0, 255).astype(np.uint8)
    edge = np.zeros((size, size), dtype=np.uint8)
    edge[:, size // 2:] = 255
    return {'noise': noise, 'smooth': smooth, 'edge': edge, 'white': np.full((size, size), 255, dtype=np.uint8)}


def run_models(np, cfg, img):
    wy, wx, W2 = cfg.weights2d()
    ry, rx = cfg.ry, cfg.rx
    H, Wd = img.shape
    pad = np.pad(img, ((ry, ry), (rx, rx)), mode='reflect')
    out = {}

    # ---- float64 reference
    ref = np.zeros((H, Wd))
    for dy, dx in cfg.taps:
        ref += W2[dy + ry][dx + rx] * pad[ry + dy:ry + dy + H, rx + dx:rx + dx + Wd]
    out['f64'] = np.clip(np.floor(ref + 0.5), 0, 255).astype(np.int64)

    # ---- project scalar reference (float32, no FMA, row-major taps)
    f32 = np.float32
    ws = {}
    tot = f32(0)
    for dy, dx in cfg.taps:
        e = f32(-(dx * dx) / (2 * f32(cfg.sx) * f32(cfg.sx)) - (dy * dy) / (2 * f32(cfg.sy) * f32(cfg.sy)))
        ws[(dy, dx)] = np.exp(e).astype(f32)
        tot = f32(tot + ws[(dy, dx)])
    pf = pad.astype(f32)
    val = np.zeros((H, Wd), dtype=f32)
    for dy, dx in cfg.taps:
        val = val + (ws[(dy, dx)] / tot) * pf[ry + dy:ry + dy + H, rx + dx:rx + dx + Wd]
    out['scalar'] = np.clip(np.floor(val + f32(0.5)), 0, 255).astype(np.int64)

    # ---- float32 FMA schedules
    def fma(a, c, acc):                  # single rounding, via float64 (a*c exact in float64)
        return (a.astype(np.float64) * np.float64(c) + acc.astype(np.float64)).astype(f32)

    def conv_f32(a, wts, r, axis, sym):
        n = a.shape[axis] - 2 * r
        sl = (lambda o: (slice(None), slice(r + o, r + o + n))) if axis == 1 else (lambda o: (slice(r + o, r + o + n), slice(None)))
        if sym:
            acc = a[sl(0)] * f32(wts[r])
            for j in range(1, r + 1):
                acc = fma(a[sl(-j)] + a[sl(j)], f32(wts[r + j]), acc)
            return acc
        acc = a[sl(-r)] * f32(wts[0])
        for d in range(-r + 1, r + 1):
            acc = fma(a[sl(d)], f32(wts[r + d]), acc)
        return acc

    def finish_f32(acc):
        return np.clip(np.rint(acc), 0, 255).astype(np.int64)

    acc = None
    for dy, dx in cfg.taps:
        src = pf[ry + dy:ry + dy + H, rx + dx:rx + dx + Wd]
        c = f32(W2[dy + ry][dx + rx])
        acc = src * c if acc is None else fma(src, c, acc)
    out['f32:direct'] = finish_f32(acc)
    if cfg.separable:
        for key, sym in (('f32:sep', False), ('f32:sep_sym', True)):
            out[key] = finish_f32(conv_f32(conv_f32(pf, wx, rx, 1, sym), wy, ry, 0, sym).astype(f32))

    # ---- fixed point
    def mulhrs(v, w):
        c15 = min(int(round(w * 32768)), 32767)
        return (v * c15 + 16384) >> 15

    def conv_q(a, wts, r, axis, sym):
        n = a.shape[axis] - 2 * r
        sl = (lambda o: (slice(None), slice(r + o, r + o + n))) if axis == 1 else (lambda o: (slice(r + o, r + o + n), slice(None)))
        if sym:
            o = mulhrs(a[sl(0)], wts[r])
            for j in range(1, r + 1):
                pair = a[sl(-j)] + a[sl(j)]
                assert pair.max() <= 32767, 'pair sum overflows signed 16 bits'
                o = o + mulhrs(pair, wts[r + j])
        else:
            o = mulhrs(a[sl(-r)], wts[0])
            for d in range(-r + 1, r + 1):
                o = o + mulhrs(a[sl(d)], wts[r + d])
        assert o.max() <= 32767, 'intermediate overflows signed 16 bits'
        return o

    x = pad.astype(np.int64)
    q = 7
    acc = None
    for dy, dx in cfg.taps:
        t = mulhrs(x[ry + dy:ry + dy + H, rx + dx:rx + dx + Wd] << q, W2[dy + ry][dx + rx])
        acc = t if acc is None else acc + t
    assert acc.max() <= 32767, 'direct sum overflows signed 16 bits'
    out['u16:direct'] = np.clip((acc * (1 << (15 - q)) + 16384) >> 15, 0, 255)
    if cfg.separable:
        for key, sym, q in (('u16:sep', False, 7), ('u16:sep_sym', True, 6)):
            xq = x << q
            tmp = conv_q(xq, wx, rx, 1, sym)
            acc = conv_q(tmp, wy, ry, 0, sym)
            out[key] = np.clip((acc * (1 << (15 - q)) + 16384) >> 15, 0, 255)
    return out


def fixed_point_bound(cfg, acc_key):
    """Worst-case |fixed-point result - exact| in output levels before the final rounding, from the number of
    rounding multiplies on any path: each vpmulhrsw tap adds <= 0.5 Q-unit rounding plus <= vmax * 2^-16 from
    quantizing its coefficient to 15 bits (vmax <= 32640 Q-units): about 1 Q-unit per tap per stage. The weights
    of each stage sum to 1, so earlier-stage error is not amplified."""
    if acc_key == 'direct':
        n, q = len(cfg.taps), 7
    elif acc_key == 'sep':
        n, q = cfg.kx + cfg.ky, 7
    else:
        n, q = (cfg.rx + 1) + (cfg.ry + 1), 6
    eps = 0.5 + 32640.0 / 65536.0
    return n * eps / (1 << q)


def binom_models(np, cfg, img, nx, ny):
    """Exact vpavgb cascade (avg = (a + b + 1) >> 1) and the float64 ideal binomial of the same stage counts."""
    p = max(nx, ny)
    pad = np.pad(img.astype(np.int64), ((ny, ny), (nx, nx)), mode='reflect')

    def stage(a, axis):
        n = a.shape[axis] - 2
        sl = (lambda o: (slice(None), slice(1 + o, 1 + o + n))) if axis == 1 else (lambda o: (slice(1 + o, 1 + o + n), slice(None)))
        return ((((a[sl(-1)] + a[sl(1)] + 1) >> 1) + a[sl(0)] + 1) >> 1)

    a = pad
    for _ in range(nx):
        a = stage(a, 1)
    for _ in range(ny):
        a = stage(a, 0)
    def binom(n):
        c = [1.0]
        for _ in range(2 * n):
            c = [x + y for x, y in zip([0.0] + c, c + [0.0])]
        return [v / sum(c) for v in c]
    wxb, wyb = binom(nx), binom(ny)
    f = img.astype(np.float64)
    pf = np.pad(f, ((ny, ny), (nx, nx)), mode='reflect')
    H, Wd = img.shape
    t = sum(wxb[k] * pf[:, k:k + Wd] for k in range(2 * nx + 1))
    ideal = sum(wyb[k] * t[k:k + H, :] for k in range(2 * ny + 1))
    return a, np.clip(np.floor(ideal + 0.5), 0, 255).astype(np.int64)


def accuracy(cfg, kind, acc_key, size=160, nstages=None):
    try:
        import numpy as np
    except Exception:
        return None
    imgs = make_images(np, size)
    if kind == 'u8':
        worst = dict(scalar=0.0, f64=0.0, ideal=0.0)
        maxd = dict(scalar=0, f64=0, ideal=0)
        mean = 0.0
        for nm, img in imgs.items():
            m = run_models(np, cfg, img)
            out, ideal = binom_models(np, cfg, img, nstages[0], nstages[1])
            for ref, other in (('scalar', m['scalar']), ('f64', m['f64']), ('ideal', ideal)):
                diff = np.abs(out - other)
                worst[ref] = max(worst[ref], float((diff != 0).mean()))
                maxd[ref] = max(maxd[ref], int(diff.max()))
        return dict(mm_scalar=worst['scalar'], max_scalar=maxd['scalar'], mm_f64=worst['f64'], max_f64=maxd['f64'],
                    bound=None, mm_ideal=worst['ideal'], max_ideal=maxd['ideal'])
    key = '%s:%s' % (kind, acc_key)
    worst = dict(scalar=0.0, f64=0.0)
    maxd = dict(scalar=0, f64=0)
    for nm, img in imgs.items():
        m = run_models(np, cfg, img)         # also asserts no overflow (white image = monotone worst case)
        for ref in ('scalar', 'f64'):
            diff = np.abs(m[key] - m[ref])
            worst[ref] = max(worst[ref], float((diff != 0).mean()))
            maxd[ref] = max(maxd[ref], int(diff.max()))
    bound = fixed_point_bound(cfg, acc_key) if kind == 'u16' else None
    return dict(mm_scalar=worst['scalar'], max_scalar=maxd['scalar'], mm_f64=worst['f64'], max_f64=maxd['f64'], bound=bound)


# ---------------------------------------------------------------------------------------------------
# Bandwidth loading, reporting
# ---------------------------------------------------------------------------------------------------
def load_bandwidth(bw_dir):
    gbps = dict((s, dict(v)) for s, v in MEASURED_GBPS.items())
    src = 'built-in medians from roofs.md'
    if bw_dir and os.path.isdir(bw_dir):
        samples = {}
        for fn in sorted(os.listdir(bw_dir)):
            if fn.startswith('bw') and fn.endswith('.csv'):
                for r in csv.DictReader(open(os.path.join(bw_dir, fn))):
                    samples.setdefault((r['scope'], r['level']), []).append(float(r['traffic_GBps']))
        if samples:
            for scope, key in BW_SCOPE.items():
                for lvl in ('L1', 'L2', 'L3', 'DRAM'):
                    if (key, lvl) in samples:
                        gbps[scope][lvl] = statistics.median(samples[(key, lvl)])
            src = 'median of benchmark_results/.../roofline/bw*.csv'
    return gbps, src


def fmt_mpix(v):
    if v == float('inf'):
        return 'inf'
    return '%.0f' % (v / 1e6) if v < 1e10 else '%.2e' % (v / 1e6)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--configs', nargs='+', default=['0.8:3', '1.4:3', '1.4:5', '2:9', '3:13', '1.5:3:5:15', '1.4:5d'])
    ap.add_argument('--sizes', nargs='+', default=['1920x1080'], help='WxH list')
    ap.add_argument('--scope', choices=['one_core', 'node'], default='one_core',
                    help='node = both sockets, 16 cores, NUMA-local halves')
    ap.add_argument('--ghz', type=float, default=3.0,
                    help='assumed sustained AVX2 clock (default 3.0; the 4208 max single-core turbo is 3.2, '
                         'project docs saw 3.0-3.2 on a quiet core; all-core sustained is not measured)')
    ap.add_argument('--regs', type=int, default=32,
                    help='ymm registers: 16 = plain AVX2; 32 needs EVEX encodings (AVX512VL, +BW for integer ops)')
    ap.add_argument('--l1-frac', type=float, default=0.75, help='fraction of L1d the tile working set may use')
    ap.add_argument('--types', nargs='+', default=['f32', 'u16', 'u8'], choices=['f32', 'u16', 'u8'])
    ap.add_argument('--bw-dir', default=os.path.join(HERE, '..', 'benchmark_results', '20261023T202123Z-3937632', 'roofline'))
    ap.add_argument('--vblock', type=int, default=4, help='output rows per vertical/direct group; each candidate takes '
                                                          'the better of R=1 and this (column R)')
    ap.add_argument('--allow-approx', action='store_true', help='let the binomial vpavgb approximations compete for the *')
    ap.add_argument('--no-accuracy', action='store_true')
    ap.add_argument('--schedule', action='store_true', help='print register liveness and instruction template per pass')
    ap.add_argument('--detail', action='store_true', help='print uop counts per 32 pixels')
    ap.add_argument('--csv')
    args = ap.parse_args()

    gbps, bw_src = load_bandwidth(args.bw_dir)
    bw = gbps[args.scope]
    n = CORES[args.scope]
    print('Gaussian blur (uint8 -> uint8, reflected borders): OPTIMISTIC RESOURCE BOUNDS, Xeon Silver 4208 (Cascade Lake)')
    print('scope=%s (%d physical core%s)  assumed f=%.2f GHz  ymm regs=%d%s  L1 tile budget=%.0f%%'
          % (args.scope, n, '' if n == 1 else 's', args.ghz, args.regs,
             ' (EVEX forms assumed same cost)' if args.regs > 16 else '', args.l1_frac * 100))
    print('bandwidth GB/s (%s): L2 %.1f  L3 %.1f  DRAM %.1f   spec DRAM roof %.1f'
          % (bw_src, bw['L2'], bw['L3'], bw['DRAM'], SPEC_DRAM_GBPS[args.scope]))
    print('bound = max(sum of loop-phase compute bounds, memory) per streaming group; barrier groups add. '
          'Residency by footprint is an approximation.')

    rows, acc_cache = [], {}
    cfgs = [parse_config(c) for c in args.configs]
    sizes = [tuple(int(v) for v in s.lower().split('x')) for s in args.sizes]
    for W, H in sizes:
        print('\n' + '=' * 150)
        print('IMAGE %dx%d   (* = highest modeled bound for the configuration)' % (W, H))
        for cfg in cfgs:
            results = {}
            for R in sorted(set([1, max(1, args.vblock)])):
                for c in build_candidates(cfg, args.types, args.regs, R):
                    e = evaluate(c, cfg, W, H, args.scope, args.ghz, args.l1_frac, bw)
                    if c['name'] not in results or e['r'] > results[c['name']][1]['r'] * (1 + 1e-9):
                        results[c['name']] = (c, e)
            print('\n[%s]  %s' % (cfg.label, cfg.desc()))
            if cfg.separable:
                print('  ideal mult/px: direct %d, separable %d, separable+sym %d'
                      % (len(cfg.taps), cfg.kx + cfg.ky, (cfg.kx // 2 + 1) + (cfg.ky // 2 + 1)))
            else:
                print('  disk support is not separable: only direct 2D (%d taps) is valid' % len(cfg.taps))
            pool = [v for v in results.values() if args.allow_approx or not v[0].get('approx')]
            best = max(pool or results.values(), key=lambda t: t[1]['r'])[0]['name']
            hdr = '  %-1s %-18s %2s %7s  %-30s %-5s %5s %9s %9s %9s %-14s %7s %-12s %-12s %-9s'
            print(hdr % ('', 'implementation', 'R', 'cyc/px', 'phase bounds (cycles/px)', 'regs', 'tile', 'core Mpx/s',
                         'mem Mpx/s', 'bound Mpx/s', 'limit', 'ms/img', 'vs scalar', 'vs f64', 'err bound'))
            for name, (c, e) in results.items():
                acc = None
                if not args.no_accuracy:
                    k = (cfg.label, c['kind'], c['acc_key'], c.get('nstages'))
                    if k not in acc_cache:
                        acc_cache[k] = accuracy(cfg, c['kind'], c['acc_key'], nstages=c.get('nstages'))
                    acc = acc_cache[k]
                phases = '|'.join(' '.join('%s:%.2f%s' % (p[0], p[2], '*' if p[1] == 'dependency' else '') for p in g)
                                  for g in e['bounds'])
                regs_used = max(p.live.get('live', 0) for g in c['groups'] for p in g)
                reload = any(not p.live.get('held', True) for g in c['groups'] for p in g)
                regs_s = '%d%s' % (regs_used, 'r' if reload else '')
                tile = '%d' % e['tx'] if c['buffered'] else 'full'
                limit = '/'.join('%s:%s' % (l, lim) for l, lim in zip(e['levels'], e['limits']))
                ms = W * H / e['r'] * 1e3
                if acc is None:
                    vs_s = vs_f = eb = '-'
                else:
                    vs_s = '%.1f%%/%d' % (100 * acc['mm_scalar'], acc['max_scalar'])
                    vs_f = '%.1f%%/%d' % (100 * acc['mm_f64'], acc['max_f64'])
                    eb = 'APPROX' if c.get('approx') else ('-' if acc['bound'] is None else '%.3f lvl' % acc['bound'])
                print(hdr % ('*' if name == best else '', name, c['R'], '%.3f' % e['cyc'], phases[:30], regs_s, tile,
                             fmt_mpix(e['r_core']), fmt_mpix(e['r_mem']), fmt_mpix(e['r']), limit[:14], '%.3f' % ms,
                             vs_s, vs_f, eb))
                if c.get('approx'):
                    avgs = sum(p.res.ops.get('pavgb', 0) + p.res.ops.get('pavgb+ld', 0) for g in c['groups'] for p in g)
                    arith = avgs / 2.0
                    line = ('       different filter (binomial %dx%d taps): vpavgb-only bound %.4f cyc/px (%.1f px/cycle, %.0f avgs/32px); '
                            'completed-kernel bound %.4f cyc/px = %.1fx slower than the arithmetic peak'
                            % (2 * c['nstages'][0] + 1, 2 * c['nstages'][1] + 1, arith, 1.0 / arith, avgs * 32,
                               e['cyc'], e['cyc'] / arith))
                    print(line)
                    if acc is not None:
                        print('       error vs requested kernel: %.0f%% of pixels differ, max %d levels; vs exact binomial of the same size (pure vpavgb rounding): '
                              '%.0f%% differ, max %d' % (100 * acc['mm_f64'], acc['max_f64'], 100 * acc['mm_ideal'], acc['max_ideal']))
                rows.append(dict(width=W, height=H, scope=args.scope, ghz=args.ghz, config=cfg.label, impl=name, R=c['R'],
                                 core_cycles_per_px=e['cyc'], phases=phases, levels='/'.join(e['levels']),
                                 limits='/'.join(e['limits']), tile=e['tx'], core_mpix_s=e['r_core'] / 1e6,
                                 mem_mpix_s=e['r_mem'] / 1e6, bound_mpix_s=e['r'] / 1e6,
                                 mismatch_scalar_pct=None if acc is None else 100 * acc['mm_scalar'],
                                 mismatch_f64_pct=None if acc is None else 100 * acc['mm_f64'],
                                 fixed_point_err_bound_levels=None if acc is None else acc['bound']))
                if args.schedule or args.detail:
                    for g in c['groups']:
                        for p in g:
                            if args.schedule:
                                for line in p.sched:
                                    print('       ' + line)
                            if args.detail:
                                r32 = p.res.scaled(32)
                                parts = ', '.join('%s %.1f' % (k, v) for k, v in sorted(r32.ops.items()))
                                print('       [%s] per 32 px: slots %.1f, loads %.1f (+%.1f split), stores %.1f, '
                                      'dependency %.2f cyc/px | %s' % (p.name, r32.slots, r32.loads, r32.split,
                                                                       r32.stores, p.dep, parts))
    if args.csv:
        with open(args.csv, 'w') as f:
            w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
            w.writeheader()
            w.writerows(rows)
        print('\nwrote %s' % args.csv)
    print('\nphase bounds: widen / H / V / direct, each = max(ports, issue, loads, stores, dependency); "*" = dependency-bound; '
          '"|" separates full-image barrier groups.')
    print('regs: peak live ymm registers of the schedule ("r" = coefficients reloaded from memory to leave room for chains).')
    print('vs scalar / vs f64: worst mismatch fraction/max |diff| over noise, smooth, edge images against the project scalar blur '
          '(float32, no FMA) / exact float64.')
    print('err bound: guaranteed worst-case fixed-point error before the final round (levels); an overflow assert on an all-255 '
          'image proves no stage overflows signed 16 bits, since all weights are non-negative.')
    print('binom_avg rows approximate the Gaussian with cascaded [1 2 1] vpavgb stages; they are excluded from * unless --allow-approx.')
    print('Bounds, not measurements: validate with the compiled loop (make count style) and a pinned driver.')


if __name__ == '__main__':
    main()
