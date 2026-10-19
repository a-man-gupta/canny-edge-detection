#!/usr/bin/env python3
"""Run library and executable adapters, keeping raw samples and explicit skips."""
import argparse
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import subprocess
import sys
import time
import cv2
import numpy as np

ROOT = Path(__file__).resolve().parents[1]
STAGES = ['h2d_ms', 'blur_ms', 'sobel_ms', 'nms_ms', 'threshold_ms', 'hysteresis_ms', 'canny_ms', 'fused_ms', 'd2h_ms']


def metrics(actual, expected):
    a, b = actual != 0, expected != 0
    tp = int(np.count_nonzero(a & b))
    fp = int(np.count_nonzero(a & ~b))
    fn = int(np.count_nonzero(~a & b))
    return {'agreement_pct': float(np.mean(a == b) * 100),
            'f1': 2*tp/(2*tp+fp+fn) if 2*tp+fp+fn else 1.0,
            'precision': tp/(tp+fp) if tp+fp else float(not np.any(b)),
            'recall': tp/(tp+fn) if tp+fn else 1.0,
            'edge_density': float(np.mean(a)), 'tp': tp, 'fp': fp, 'fn': fn}


def validate(payload, iterations, shape, output):
    samples = payload['samples']
    if len(samples) != iterations:
        raise ValueError(f'Expected {iterations} samples, received {len(samples)}')
    keys = set(samples[0])
    for row in samples:
        if set(row) != keys or not {'compute_ms', 'e2e_ms'} <= keys:
            raise ValueError('Sample keys must be consistent and include compute_ms/e2e_ms')
        for key, value in row.items():
            if not key.endswith('_ms') or not isinstance(value, (int, float)) or not math.isfinite(value) or value < 0:
                raise ValueError(f'Invalid timing {key}: {value}')
        if row['compute_ms'] <= 0 or row['e2e_ms'] <= 0:
            raise ValueError('Total timings must be positive')
        if row['compute_ms'] > row['e2e_ms'] * 1.05 + .01:
            raise ValueError('Compute time exceeds end-to-end time')
    if output is None or output.shape != shape or output.dtype != np.uint8:
        raise ValueError('Missing or invalid output image')
    if not np.isin(output, [0, 255]).all():
        raise ValueError('Output must be a binary 0/255 edge map')


def opencv_cpu(image, threads, a):
    cv2.setNumThreads(threads)
    cv2.ocl.setUseOpenCL(False)
    rows = []
    blurred = np.empty_like(image)
    edges = np.empty_like(image)
    for i in range(-a.warmup, a.iterations):
        start = time.perf_counter_ns()
        cv2.GaussianBlur(image, (5, 5), a.sigma, dst=blurred, sigmaY=a.sigma, borderType=cv2.BORDER_REFLECT_101)
        split = time.perf_counter_ns()
        cv2.Canny(blurred, a.low, a.high, edges=edges, apertureSize=3, L2gradient=True)
        end = time.perf_counter_ns()
        if i >= 0:
            rows.append({'compute_ms': (end-start)/1e6, 'e2e_ms': (end-start)/1e6,
                         'blur_ms': (split-start)/1e6, 'canny_ms': (end-split)/1e6})
    return {'timing_method': 'perf_counter_ns; preallocated outputs; OpenCL off; OpenCV internal allocations included',
            'actual_opencv_threads': cv2.getNumThreads(), 'samples': rows}, edges.copy()


def write_csv(path, rows):
    if not rows:
        return
    fields = list(dict.fromkeys(key for row in rows for key in row))
    with path.open('w', newline='') as f:
        writer = csv.DictWriter(f, fields)
        writer.writeheader()
        writer.writerows(rows)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--manifest', type=Path, default=ROOT/'benchmark_data/manifest.json')
    p.add_argument('--output', type=Path, required=True, help='New directory; existing output is rejected')
    p.add_argument('--iterations', type=int, default=100)
    p.add_argument('--warmup', type=int, default=10)
    p.add_argument('--low', type=float, default=50)
    p.add_argument('--high', type=float, default=100)
    p.add_argument('--sigma', type=float, default=1.4)
    p.add_argument('--threads', type=int, default=0, help='OpenCV multi baseline: 0 = detected CPU count; record actual threads')
    p.add_argument('--implementations', nargs='+', default=['scalar', 'opencv-1', 'opencv-multi', 'opencv-cuda'])
    p.add_argument('--adapters', type=Path, help='JSON mapping names to executable argument arrays')
    p.add_argument('--case', nargs='+', help='Run only these exact case names')
    p.add_argument('--timeout', type=float, default=7200, help='Seconds per external executable/case')
    p.add_argument('--min-f1', type=float, help='Fail if any scalar-reference comparison falls below this value')
    a = p.parse_args()
    if a.iterations < 1 or a.warmup < 0 or a.threads < 0 or not all(math.isfinite(x) for x in [a.low,a.high,a.sigma,a.timeout]) or not 0 <= a.low < a.high or a.sigma <= 0 or a.timeout <= 0:
        p.error('Invalid iterations, warmup, threads, thresholds, sigma or timeout')
    if a.min_f1 is not None and not 0 <= a.min_f1 <= 1:
        p.error('--min-f1 must be in [0,1]')
    if a.min_f1 is not None and 'scalar' not in a.implementations:
        p.error('--min-f1 requires scalar in --implementations')
    adapters = {'scalar': [str(ROOT/'build/canny_scalar')], 'opencv-cuda': [str(ROOT/'build/canny_opencv_cuda')]}
    if a.adapters:
        custom = json.loads(a.adapters.read_text())
        for name, cmd in custom.items():
            if name in ['scalar', 'opencv-1', 'opencv-multi', 'opencv-cuda']:
                p.error(f'Cannot override builtin {name}')
            if not isinstance(cmd, list) or not cmd or not all(isinstance(v,str) for v in cmd):
                p.error(f'Adapter {name} must be a nonempty argument array')
        adapters.update(custom)
    for name in a.implementations:
        if name not in ['opencv-1','opencv-multi'] and name not in adapters:
            p.error(f'Unknown implementation: {name}')
    if len(set(a.implementations)) != len(a.implementations):
        p.error('Duplicate implementations')
    manifest = json.loads(a.manifest.read_text())
    cases = manifest['cases']
    if a.case:
        missing = set(a.case) - {c['name'] for c in cases}
        if missing:
            p.error(f'Unknown cases: {missing}')
        cases = [c for c in cases if c['name'] in a.case]
    if not cases:
        p.error('No cases selected')
    # A vectorized self-check protects accuracy reports from incompatible numerical builds.
    check_image = np.zeros((480,640),np.uint8)
    check_image[10:400:3,100:500:7] = 255
    self_check = metrics(check_image,check_image)
    if self_check['f1'] != 1 or self_check['agreement_pct'] != 100:
        raise RuntimeError(f'NumPy {np.__version__} failed the accuracy preflight; reinstall requirements-bench.txt in a clean supported environment')
    a.output.mkdir(parents=True, exist_ok=False)
    (a.output/'edges').mkdir()
    (a.output/'native_logs').mkdir()
    def git(*args):
        r = subprocess.run(['git', '-C', str(ROOT), *args], capture_output=True, text=True)
        return r.stdout.strip() if r.returncode == 0 else 'unavailable'
    metadata = {'schema_version': 1, 'utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                'command': sys.argv, 'parameters': {k: str(v) if isinstance(v,Path) else v for k,v in vars(a).items()},
                'platform': platform.platform(), 'python': sys.version, 'numpy': np.__version__, 'opencv': cv2.__version__,
                'git_commit': git('rev-parse','HEAD'), 'git_status': git('status','--porcelain'),
                'git_diff': git('diff','HEAD'), 'manifest': manifest, 'adapters': adapters,
                'cpu_affinity': sorted(os.sched_getaffinity(0)) if hasattr(os,'sched_getaffinity') else None,
                'environment': {k: os.environ.get(k) for k in ['CUDA_VISIBLE_DEVICES','OMP_NUM_THREADS','OPENBLAS_NUM_THREADS']}}
    for name, cmd in adapters.items():
        exe = Path(cmd[0])
        if exe.is_file():
            metadata.setdefault('executable_sha256', {})[name] = hashlib.sha256(exe.read_bytes()).hexdigest()
    (a.output/'metadata.json').write_text(json.dumps(metadata, indent=2)+'\n')
    (a.output/'opencv_build.txt').write_text(cv2.getBuildInformation())
    raw, summary, accuracy, statuses = [], [], [], []
    failures = 0
    for case in cases:
        input_path = (a.manifest.resolve().parent / case['path']).resolve()
        if hashlib.sha256(input_path.read_bytes()).hexdigest() != case['sha256']:
            raise ValueError(f'Fixture hash changed: {input_path}')
        image = cv2.imread(str(input_path), cv2.IMREAD_GRAYSCALE)
        if image is None or image.shape != (case['height'],case['width']):
            raise ValueError(f'Invalid fixture: {input_path}')
        # Untimed CPU OpenCV correctness reference, fixed to one thread.
        cv2.setNumThreads(1); cv2.ocl.setUseOpenCL(False)
        reference = cv2.Canny(cv2.GaussianBlur(image,(5,5),a.sigma,sigmaY=a.sigma,borderType=cv2.BORDER_REFLECT_101),a.low,a.high,apertureSize=3,L2gradient=True)
        outputs = {}
        for index, name in enumerate(a.implementations):
            # Numeric filenames avoid interpreting adapter names as paths.
            stem = f'{case["name"]}_{index}'
            output_path = a.output/'edges'/f'{stem}.pgm'
            print(f'{case["name"]}: {name}', flush=True)
            status = {'case': case['name'], 'implementation': name}
            try:
                if name.startswith('opencv-') and name != 'opencv-cuda':
                    threads = 1 if name == 'opencv-1' else (a.threads or (os.cpu_count() or 1))
                    payload, output = opencv_cpu(image, threads, a)
                    if not cv2.imwrite(str(output_path),output):
                        raise RuntimeError('Cannot write edge map')
                else:
                    cmd = adapters[name]
                    if not Path(cmd[0]).is_file():
                        if name not in ['scalar','opencv-cuda']:
                            raise FileNotFoundError(f'Configured adapter missing: {cmd[0]}')
                        status.update(status='skipped', reason=f'Executable not built: {cmd[0]}')
                        statuses.append(status)
                        continue
                    command = [*cmd, '--input',str(input_path),'--output',str(output_path.resolve()),
                               '--iterations',str(a.iterations),'--warmup',str(a.warmup),
                               '--low',str(a.low),'--high',str(a.high),'--sigma',str(a.sigma)]
                    result = subprocess.run(command,capture_output=True,text=True,timeout=a.timeout)
                    (a.output/'native_logs'/f'{stem}.stdout').write_text(result.stdout)
                    (a.output/'native_logs'/f'{stem}.stderr').write_text(result.stderr)
                    if result.returncode:
                        raise RuntimeError(f'Executable returned {result.returncode}; see native_logs/{stem}.stderr')
                    payload = json.loads(result.stdout)
                    output = cv2.imread(str(output_path),cv2.IMREAD_GRAYSCALE)
                validate(payload,a.iterations,image.shape,output)
                outputs[name] = output
                for i, row in enumerate(payload['samples']):
                    raw.append({'case':case['name'],'implementation':name,'iteration':i,**row})
                entry = {'case':case['name'],'axis':case['axis'],'kind':case['kind'],
                         'width':case['width'],'height':case['height'],'implementation':name,
                         'iterations':a.iterations,'timing_method':payload.get('timing_method','unspecified'),
                         'opencv_threads':payload.get('actual_opencv_threads','')}
                for key in payload['samples'][0]:
                    values = [r[key] for r in payload['samples']]
                    entry[f'{key}_median'] = float(np.median(values))
                    entry[f'{key}_p95'] = float(np.percentile(values,95))
                pixels = image.size
                entry['compute_mpix_s'] = pixels / entry['compute_ms_median'] / 1000
                entry['e2e_mpix_s'] = pixels / entry['e2e_ms_median'] / 1000
                summary.append(entry)
                status.update(status='ok')
            except Exception as e:
                status.update(status='failed',reason=str(e));failures += 1
            statuses.append(status)
            # Checkpoint after each implementation, even if a later large case fails.
            write_csv(a.output/'raw.csv',raw)
            write_csv(a.output/'summary.csv',summary)
            (a.output/'status.json').write_text(json.dumps(statuses,indent=2)+'\n')
        refs = {'opencv-1':reference}
        if 'scalar' in outputs:
            refs['scalar'] = outputs['scalar']
        for name, output in outputs.items():
            for refname, ref in refs.items():
                row = {'case':case['name'],'implementation':name,'reference':refname,**metrics(output,ref)}
                accuracy.append(row)
                if a.min_f1 is not None and refname=='scalar' and row['f1']<a.min_f1:
                    failures += 1
        write_csv(a.output/'accuracy.csv',accuracy)
        (a.output/'status.json').write_text(json.dumps(statuses,indent=2)+'\n')
    if a.min_f1 is not None and any(s['implementation']=='scalar' and s['status']!='ok' for s in statuses):
        failures += 1
    if not summary:
        failures += 1
    print(f'Results: {a.output}; failed checks: {failures}; skips: {sum(s["status"]=="skipped" for s in statuses)}')
    return 1 if failures else 0


if __name__ == '__main__':
    raise SystemExit(main())
