"""Build the final report figures from native run files."""
from pathlib import Path
import re
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np
import pandas as pd
here=Path(__file__).resolve().parent
root=here.parents[1]
bench=root/'benchmarks'/'final'
out=here/'figures';out.mkdir(exist_ok=True)
navy='#153e59';green='#00796b';orange='#bd6120';gray='#5e7283';light='#ebf3f3'
plt.rcParams.update({'font.size':10,'axes.spines.top':False,'axes.spines.right':False,'figure.facecolor':'white','axes.labelcolor':navy,'pdf.fonttype':42})
def save(fig,name):
    fig.tight_layout(pad=.85);fig.savefig(out/(name+'.pdf'),bbox_inches='tight');plt.close(fig)
def bars(ax,labels,series,ylabel):
    x=np.arange(len(labels));step=.8/len(series)
    for i,(title,vals,color) in enumerate(series):
        b=ax.bar(x+(i-(len(series)-1)/2)*step,vals,.90*step,label=title,color=color)
        ax.bar_label(b,fmt='%.2f',padding=2,fontsize=8)
    ax.set_xticks(x,labels);ax.set_ylabel(ylabel);ax.grid(axis='y',alpha=.17);ax.set_axisbelow(True);ax.legend(frameon=False,fontsize=8)
    ax.set_ylim(0,ax.get_ylim()[1]*1.13)
fusion=pd.read_csv(bench/'fusion/results.csv')
images=['photo-1920','canny-apollo-native4k']
def times(n,mode,col='median_ms'):
    data=fusion[(fusion.threads==n)&(fusion['mode']==mode)].set_index('image')
    return [data.loc[im,col] for im in images]
fig,ax=plt.subplots(figsize=(7,2.85))
bars(ax,['1920 × 1080','3840 × 2160'],[('Scalar (1 core)',times(1,'row','scalar_ms'),gray),('SIMD tiles (1 core)',times(1,'row'),navy),('SIMD tiles (8 cores)',times(8,'row'),green)],'Frame time (ms)')
save(fig,'frames')
fig,ax=plt.subplots(figsize=(7,2.85))
bars(ax,['1080p · 1 core','1080p · 8','4K · 1','4K · 8'],[(name,[times(1,mode)[0],times(8,mode)[0],times(1,mode)[1],times(8,mode)[1]],col) for mode,name,col in [('separate','Five stages',gray),('staged','Blur materialized',navy),('row','Fused tiles',green)]],'Frame time (ms)')
save(fig,'fusion')
fig,axes=plt.subplots(1,2,figsize=(7,2.65))
for ax,stage,ops,peak in zip(axes,['sobel','nms'],[10.9,26],[48,3328/(248/3)]):
    for width,col,marker in [(128,green,'o'),(256,navy,'s')]:
        p=pd.read_csv(bench/f'l1/w{width}.csv');p=p[(p.stage==stage)&(p.event=='cycles')].copy()
        p['rate']=ops/p.cycles_per_pixel
        g=p.groupby('groups').rate
        x=list(g.groups);m=g.median();lo=g.quantile(.25);hi=g.quantile(.75)
        ax.errorbar(x,m,yerr=[m-lo,hi-m],marker=marker,color=col,label=f'Width {width}',capsize=3)
    ax.axhline(peak,ls=':',color=orange,label='Production ALU ceiling')
    ax.set_title('Sobel' if stage=='sobel' else 'NMS + threshold')
    ax.set_xticks(x);ax.set_xlabel('16-column groups');ax.set_ylabel('Integer lane-ops/core cycle' if stage=='sobel' else '')
    ax.grid(axis='y',alpha=.16);ax.legend(frameon=False,fontsize=7);ax.set_ylim(0,52)
save(fig,'groups')
p=pd.read_csv(bench/'l1/w128.csv')
fig,ax=plt.subplots(figsize=(7,2.9))
events=['p0','p1','p2','p3','p4','p5','p6','p7']
bars(ax,events,[(label,[p[(p.stage==s)&(p.groups==g)&(p.event==e)].events_per_cycle.median()*100 for e in events],c) for label,s,g,c in [('Sobel 10 × 16','sobel',1,navy),('NMS + threshold 2 × 64','nms',4,green)]],'Port events / core cycles (%)')
ax.set_ylim(0,103);save(fig,'ports')
fig,ax=plt.subplots(figsize=(7,2.75))
for image,label,col in [('1920x1080','1080p',green),('3840x2160','4K',navy)]:
    rows=[(int(a),float(b)) for a,b in re.findall(r'^'+image+r' .*?threads=(\d+).*?total_ms=([\d.]+)',(root/'benchmarks/fusion/audit/final.log').read_text(),re.M)]
    ax.plot([n for n,t in rows],[rows[0][1]/t for n,t in rows],'-o',label=label,color=col)
ax.plot([1,16],[1,16],':',color=gray,label='Linear scaling');ax.set_xticks([1,2,4,8,16]);ax.set_xlabel('Physical cores');ax.set_ylabel('Speedup over one core');ax.legend(frameon=False);ax.grid(alpha=.16)
save(fig,'scaling')
def matrix(ax,data,title,marked=(),scale=1):
    ax.set_title(title,fontsize=10,color=navy,weight='bold');ax.axis('off')
    a=ax.table(cellText=data,cellLoc='center',loc='center')
    a.auto_set_font_size(False);a.set_fontsize(10);a.scale(1,scale)
    for (r,c),cell in a.get_celld().items():
        cell.set_facecolor(green if (r,c) in marked else light);cell.set_edgecolor('white');cell.set_linewidth(2)
        cell.get_text().set_color('white' if (r,c) in marked else navy)
fig,axes=plt.subplots(1,3,figsize=(7,1.7))
matrix(axes[0],[[22,32,48]]*3,'Blurred pixels',[(1,1)],1.55)
matrix(axes[1],[[-1,0,1],[-2,0,2],[-1,0,1]],'Horizontal gradient',scale=1.55)
matrix(axes[2],[[-1,-2,-1],[0,0,0],[1,2,1]],'Vertical gradient',scale=1.55)
save(fig,'sobel-masks')
fig,axes=plt.subplots(1,2,figsize=(7,1.75));path=[(0,0),(1,1),(2,2),(3,2)]
labels=[[2,0,0,0,1],[0,1,0,0,0],[0,0,1,0,0],[0,0,1,0,0]]
matrix(axes[0],labels,'Threshold labels',path,1.3);matrix(axes[1],[[255 if (r,c) in path else 0 for c in range(5)] for r in range(4)],'After eight-neighbor tracking',path,1.3)
save(fig,'connectivity')
fig,axes=plt.subplots(1,2,figsize=(7,2.3),gridspec_kw={'width_ratios':[1,1.3]})
matrix(axes[0],[[20,20,20,60,60],[5.45,24.42,40.26,24.42,5.45]],'Intensity and weights (%)',[(0,2),(1,2)],1.55)
bars(axes[1],['2','4','8','4 + shuffle'],[('Whole Gaussian',[1.553,1.405,1.558,1.538],green)],'Cycles/pixel')
axes[1].set_xlabel('Horizontal and vertical groups')
save(fig,'gaussian')
fig,ax=plt.subplots(figsize=(6.3,2.0))
matrix(ax,[['Rows 0, 1, 2','D0 + D1','D1 + D2','S2 − S0'],
           ['Rows 1, 2, 3','D1 + D2','D2 + D3','S3 − S1'],
           ['Rows 2, 3, 4','D2 + D3','D3 + D4','S4 − S2']],
       'Input window                 First Gx term                Second Gx term                    Gy',[(0,2),(1,1),(1,2),(2,1)],1.65)
save(fig,'sliding')
fig,axes=plt.subplots(1,4,figsize=(7,1.75))
for ax,name,a,b in zip(axes,['Horizontal','Vertical','Same signs','Opposite signs'],
                        [(1,0),(0,1),(0,0),(0,2)],[(1,2),(2,1),(2,2),(2,0)]):
    grid=[['' for c in range(3)] for r in range(3)]
    grid[1][1]='M';grid[a[0]][a[1]]='n₁';grid[b[0]][b[1]]='n₂'
    matrix(ax,grid,name,[a,b],1.42)
save(fig,'directions')
