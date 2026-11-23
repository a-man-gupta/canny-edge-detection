"""Run paired, order-balanced native 4K halo benchmarks on ECE024."""
import csv
import hashlib
import os
from pathlib import Path
import subprocess

source = Path('canny-fusion-inputs/canny-apollo-native4k.raw')
results = Path('benchmarks/fusion/results')
assert hashlib.sha256(source.read_bytes()).hexdigest() == '8c067fa2edcfbc864b530178caa22a649aca45ee74451e64227f23185a1f18d8'
env = dict(os.environ, OMP_PLACES='cores', OMP_PROC_BIND='close', CANNY_MASK_SEEDS='1')
with (results/'halo-native4k.csv').open('w') as f:
    writer = csv.writer(f)
    writer.writerow(['threads','pair','position','variant','total_ms','filter_ms','track_ms'])
    for n in (8,1):
        for pair in range(8):
            variants = ['tall','halo'] if pair%2==0 else ['halo','tall']
            for position,variant in enumerate(variants):
                edge = results/('native4k-'+variant+'-edges.raw')
                cmd = ['taskset','-c','0,2,4,6,8,10,12,14','build/canny_'+variant+'.x',
                       '3840','2160',str(n),'320','11',str(source),'row',str(edge)]
                out = subprocess.check_output(cmd,env=env,universal_newlines=True)
                assert out.rstrip().endswith('exact')
                samples = [line.split()[1:] for line in out.splitlines() if line.startswith('trial ')]
                assert len(samples)==11
                writer.writerows([n,pair,position,variant]+s for s in samples)
                f.flush()
            subprocess.run(['cmp',str(results/'native4k-tall-edges.raw'),
                                  str(results/'native4k-halo-edges.raw')],check=True)
            print('exact',n,pair,flush=True)
