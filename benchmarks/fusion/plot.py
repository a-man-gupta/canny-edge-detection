"""Render the ECE024 CSV results and exact input/edge previews."""
import argparse
import csv
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from PIL import Image

p=argparse.ArgumentParser()
p.add_argument('inputs',type=Path)
p.add_argument('results',type=Path)
a=p.parse_args()
def read(name):
    with (a.results/name).open() as f:
        return list(csv.DictReader(f))
def values(rows,column,**keys):
    return np.array([float(r[column]) for r in rows if all(r[k]==str(v) for k,v in keys.items())])
def save(fig,name):
    fig.tight_layout()
    fig.savefig(a.results/name,dpi=160,bbox_inches='tight')
    plt.close(fig)
seeds=read('seeds.csv')
trials=read('trials.csv')
cases=[(1920,'photo'),(3840,'photo'),(1920,'noise'),(3840,'noise')]
names=['1080p photo','4K photo','1080p noise','4K noise']
fig,axes=plt.subplots(1,2,figsize=(12,4.4))
colors=['#616975','#439083','#16456e']
for j,(label,col,n) in enumerate([('Scalar reference','scalar_ms',1),('Fused, 1 core','total_ms',1),('Fused, 8 cores','total_ms',8)]):
    distributions=[values(seeds,col,w=w,image=img,threads=n,seed='mask') for w,img in cases]
    med=np.array([np.median(d) for d in distributions])
    err=np.array([[m-np.percentile(d,25),np.percentile(d,75)-m] for d,m in zip(distributions,med)]).T
    axes[0].bar(np.arange(4)+(j-1)*0.25,med,.24,color=colors[j],label=label,yerr=err,capsize=2)
axes[0].set(yscale='log',ylabel='Wall time (ms, log scale)',title='Full Canny pipeline')
axes[0].legend(fontsize=8)
for j,(seed,label) in enumerate([('block','Block rescan'),('mask','Exact SIMD seed mask')]):
    med=[np.median(values(seeds,'track_ms',w=w,image=img,threads=8,seed=seed)) for w,img in cases]
    axes[1].bar(np.arange(4)+(j-.5)*.37,med,.35,color=colors[j+1],label=label)
axes[1].set(ylabel='Hysteresis time (ms)',title='Eight cores, same edge output')
axes[1].legend(fontsize=8)
for ax in axes:
    ax.set_xticks(range(4),names,rotation=15)
    ax.spines[['right','top']].set_visible(False)
save(fig,'performance.png')
fig,axes=plt.subplots(1,2,figsize=(11.5,4))
for v,rows in [('tiled',4),('tall',8)]:
    for mode,style in [('row','-o'),('morton','--s')]:
        y=[np.median(values(trials,'filter_ms',phase='screen',variant=v,mode=mode,strip=s)) for s in (128,256,320)]
        axes[0].plot([128,256,320],y,style,label=f'{rows} rows, {mode}')
axes[0].set(xlabel='Strip width (pixels)',ylabel='Filter through threshold (ms)',title='1080p photo, eight cores')
axes[0].legend(fontsize=8)
for w in (1920,3840):
    for img in ('photo','noise'):
        vals=[np.median(values(trials,'total_ms',phase='confirm',w=w,image=img,variant='tall',mode='row',strip=320,threads=n)) for n in (1,2,4,8)]
        axes[1].plot([1,2,4,8],vals[0]/np.array(vals),'-o',label=f'{w} wide, {img}')
axes[1].plot([1,8],[1,8],':',color='gray',label='Ideal')
axes[1].set(xlabel='Physical cores',ylabel='Speedup over one core',title='OpenMP scaling with block seeding',xticks=[1,2,4,8])
axes[1].legend(fontsize=8)
save(fig,'layout-scaling.png')
fig,axes=plt.subplots(2,2,figsize=(8,5.2))
for j,(w,h) in enumerate([(1920,1080),(3840,2160)]):
    for i,(file,title) in enumerate([(a.inputs/f'photo-{w}.raw','Input'),(a.results/f'photo-{w}-edges.raw','Verified edges')]):
        im=Image.frombytes('L',(w,h),file.read_bytes())
        im.save(a.results/f"photo-{w}-{'input' if i==0 else 'edges'}.png")
        axes[j,i].imshow(im,cmap='gray',vmin=0,vmax=255,interpolation='antialiased')
        axes[j,i].set_title(f'{w}×{h} {title.lower()}',fontsize=10)
        axes[j,i].axis('off')
save(fig,'images.png')
