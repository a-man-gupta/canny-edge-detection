"""Run from the repository root on ECE024. Standard library only."""
import argparse
import csv
import hashlib
import os
from pathlib import Path
import random
import re
import statistics
import subprocess

p=argparse.ArgumentParser()
p.add_argument('inputs',type=Path)
p.add_argument('out',type=Path)
p.add_argument('--trials',type=int,default=7)
a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=True)
env=dict(os.environ,OMP_PLACES='cores',OMP_PROC_BIND='close')
cores='0,2,4,6,8,10,12,14'
rows=[]
digests={}
def measure(w,image,variant,mode,strip,threads,phase):
    h={1920:1080,3840:2160}[w]
    source=a.inputs/('{}-{}.raw'.format(image,w))
    edge=a.out/('{}-{}-edges.raw'.format(image,w))
    if source not in digests:
        digests[source]=hashlib.sha256(source.read_bytes()).hexdigest()
    cmd=['taskset','-c',cores,'build/canny_{}.x'.format(variant),w,h,threads,strip,a.trials,source,mode,edge]
    log=subprocess.check_output(list(map(str,cmd)),env=env,universal_newlines=True)
    assert log.rstrip().endswith('exact')
    scalar=float(re.search(r'scalar_ms=([\d.]+)',log).group(1))
    times=[]
    for i,line in enumerate(line for line in log.splitlines() if line.startswith('trial ')):
        total,filt,track=map(float,line.split()[1:])
        rows.append(dict(phase=phase,w=w,h=h,image=image,variant=variant,mode=mode,strip=strip,
                         threads=threads,trial=i+1,total_ms=total,filter_ms=filt,track_ms=track,
                         scalar_median_ms=scalar,input_sha256=digests[source]))
        times.append(filt)
    assert len(times)==a.trials
    with (a.out/'trials.csv').open('w') as handle:
        writer=csv.DictWriter(handle,fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(phase,w,image,variant,mode,strip,threads,log.splitlines()[-1],flush=True)
    return statistics.median(times)

# Choose by filtering time because the sweep changes the filter, not hysteresis.
configs=[(v,m,s) for v in ('tiled','tall') for m in ('row','morton') for s in (128,256,320)]
configs.append(('tiled','staged',320))
random.Random(18645).shuffle(configs)
best=min(configs,key=lambda c:measure(1920,'photo',*c,threads=8,phase='screen'))
print('screen winner',best,flush=True)
for w in (1920,3840):
    for image in ('photo','noise'):
        cases=[(*best,n) for n in (1,2,4,8)]
        cases.extend([('tiled','staged',320,8),('tiled','row',320,8)])
        cases=list(dict.fromkeys(cases))
        random.Random(w).shuffle(cases)
        for v,m,s,n in cases:
            measure(w,image,v,m,s,n,'confirm')
