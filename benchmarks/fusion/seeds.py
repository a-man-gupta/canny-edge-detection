"""Paired follow-up on the filter configuration selected in the initial sweep."""
from pathlib import Path
import argparse
import csv
import os
import random
import statistics
import subprocess
import re

p=argparse.ArgumentParser()
p.add_argument('inputs',type=Path)
p.add_argument('out',type=Path)
a=p.parse_args()
data=list(csv.DictReader((a.out/'trials.csv').open()))
winner=next(r for r in data if r['phase']=='confirm' and r['threads']=='1')
rows=[]
for w,h in ((1920,1080),(3840,2160)):
    for image in ('photo','noise'):
        for n in (1,8):
            settings=['block','mask','mask','block']
            if (w+n)%3: settings.reverse()
            for batch,seed in enumerate(settings):
                env=dict(os.environ,OMP_PLACES='cores',OMP_PROC_BIND='close')
                env.pop('CANNY_MASK_SEEDS',None)
                if seed=='mask': env['CANNY_MASK_SEEDS']='1'
                source=a.inputs/('{}-{}.raw'.format(image,w))
                cmd=['taskset','-c','0,2,4,6,8,10,12,14','build/canny_'+winner['variant']+'.x',
                     w,h,n,winner['strip'],7,source,winner['mode']]
                log=subprocess.check_output(list(map(str,cmd)),env=env,universal_newlines=True)
                assert log.rstrip().endswith('exact')
                scalar=float(re.search(r'scalar_ms=([\d.]+)',log).group(1))
                for trial,line in enumerate(l for l in log.splitlines() if l.startswith('trial ')):
                    total,f,t=map(float,line.split()[1:])
                    rows.append(dict(w=w,h=h,image=image,threads=n,seed=seed,batch=batch,trial=trial+1,
                                     total_ms=total,filter_ms=f,track_ms=t,scalar_ms=scalar))
            with (a.out/'seeds.csv').open('w') as fh:
                wr=csv.DictWriter(fh,fieldnames=list(rows[0]));wr.writeheader();wr.writerows(rows)
            print(w,image,n,flush=True)
