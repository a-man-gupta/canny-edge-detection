"""Generate the ECE024 audit PDF from its saved benchmark logs."""
from pathlib import Path
from collections import defaultdict
import textwrap
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
A=Path(__file__).resolve().parent
def logs(name,keys):
    data=defaultdict(list)
    refs={}
    for line in (A/name).read_text().splitlines():
        s=line.split()
        if len(s)==keys: key=tuple(s)
        if s[0]=='trial': data[key].append(list(map(float,s[1:])))
        if s[-1]=='exact': refs[key]=float(next(x[10:] for x in s if x.startswith('scalar_ms=')))
    return {k:np.median(v,axis=0) for k,v in data.items()},refs
final,ref=logs('final.log',2)
queue,_=logs('queue.log',3)
scaling,_=logs('scaling.log',2)
cores=[1,2,4,8,16]
blue='#153f60'; green='#087f72'; grey='#637282'
pdf=PdfPages(A/'Canny-performance.pdf')
def page(title,subtitle):
    global fig
    fig=plt.figure(figsize=(8.5,10.4),facecolor='white')
    fig.text(.08,.94,title,fontsize=22,color=blue,weight='bold')
    fig.text(.08,.90,subtitle,fontsize=11,color=grey)
def para(y,title,body):
    fig.text(.08,y,title,fontsize=13,color=green,weight='bold',va='top')
    fig.text(.08,y-.038,'\n'.join(textwrap.wrap(body,88)),fontsize=10.8,va='top',linespacing=1.45)
def end(i):
    fig.text(.08,.035,'18-645  /  Canny edge detection     •     Xeon Silver 4208     •     November 2026',fontsize=8,color=grey)
    fig.text(.92,.035,str(i),fontsize=8,color=grey);pdf.savefig(fig);plt.close(fig)
def axes(rect):
    ax=fig.add_axes(rect);ax.spines[['right','top']].set_visible(False);ax.tick_params(labelsize=9)
    return ax
def bars(ax,labels,series,ylabel):
    x=np.arange(len(labels)); width=.74/len(series)
    for i,(name,values,color) in enumerate(series):
        ax.bar(x+(i-(len(series)-1)/2)*width,values,width*.96,label=name,color=color)
    ax.set_xticks(x,labels);ax.set_ylabel(ylabel);ax.legend(frameon=False,fontsize=9)
page('Canny on ECE024','Full-image performance  /  register pressure  /  scaling across two CPU sockets')
v=final['3840','16'][0]; u=final['3840','1'][0]
para(.84,'The result',f'The final pipeline processes a native 3840 × 2160 photograph in {v:.2f} ms using 16 physical cores, a {u/v:.1f}× speedup over its one-core time of {u:.2f} ms. Every timed run checked the intermediate labels and final edges against the scalar reference.')
ax=axes([.14,.40,.75,.27])
bars(ax,['1080p portrait','Native 4K Apollo'],[(name,[ref[w,'1'] if n==0 else final[w,str(n)][0] for w in ('1920','3840')],c) for name,n,c in [('Scalar',0,grey),('Optimized • 1 core',1,green),('Optimized • 16 cores',16,blue)]],'Frame time (ms, log scale)')
ax.set_yscale('log')
para(.32,'What changed','One 16-pixel Sobel group at a time reduces live vector state. Hysteresis now uses eight direct neighbor offsets and checks slab ends. Timing each change separately showed that the queue change delivered the larger gain.')
para(.16,'Timing scope','Median of 11 warm trials for the final build. Includes per-call workspace allocation, filtering, OpenMP synchronization and stitching. Excludes file I/O and scalar verification. The 1080p portrait and native 4K Apollo image have different content; stage times depend on the scene.')
end(1)
page('From pixels to gradients','One worker operates on a 320-column strip inside a 64-row band.')
para(.84,'1   Gaussian blur • five taps in each dimension','For sigma 1, use symmetric weights c0, c1, c2 with c0 + 2c1 + 2c2 = 32767. Widen each input byte to Q6 (pixel × 64). For each line compute M(center,c0) + M(left1 + right1,c1) + M(left2 + right2,c2), where M(a,c) = (a × c + 16384) >> 15. Apply the same formula vertically to five saved horizontal lines. Round back to bytes with (value + 32) >> 6.')
para(.62,'Hardware and reuse','A YMM register holds sixteen 16-bit lanes. VPMULHRSW applies the rounded multiply, VPADDW forms symmetric pairs, and byte packing produces the blurred row. The ring retains five horizontal rows. The fused consumer widens the local blur for Sobel. Gaussian reflects the image border.')
para(.42,'2   Sobel • ten gradient rows per block','For each source row let D = R − L and S = L + 2C + R. The kernel computes S as 2(C + R) − D. Gx = Dtop + 2Dmid + Dbottom and Gy = Sbottom − Stop. Carrying Dmid + Dbottom into the next output row saves additions. Magnitude is |Gx| + |Gy|. VPADDW, VPSUBW and VPABSW work on sixteen pixels per instruction.')
para(.19,'Why these dimensions','Eight output rows of NMS need ten rows of magnitude, which need twelve blurred rows. A 320-pixel output needs 322 gradient columns. The wrapper rounds that to 352 for the Sobel interface. The tuned kernel advances sixteen adjacent columns at a time. At image boundaries Sobel clamps blurred coordinates.')
end(2)
page('From gradients to connected edges','Three local planes feed one byte of output label per pixel.')
para(.84,'3   Non-maximum suppression • two rows × 64 columns','For each pixel set ax = |Gx|, ay = |Gy| and t = floor(ax × 27146 / 65536). Choose horizontal when ay ≤ t, vertical when ay > t + 2ax, and otherwise choose a diagonal from the signs of Gx and Gy. Keep magnitude m if m > first neighbor and m ≥ second neighbor. Four groups of sixteen lanes cover 64 columns. VPMULHUW computes t; VPMAXSW, VPCMPGTW and VPBLENDVB implement comparisons and selection.')
para(.61,'4   Double threshold • fused into the NMS register loop','For the retained magnitude, label = (m > 60) + (m > 120). A comparison gives a vector mask. Integer arithmetic and byte packing produce 0 for rejected, 1 for weak and 2 for strong. Each worker writes just the resulting labels. The outer NMS border is zero.')
para(.42,'5   Hysteresis • SIMD seeds, scalar queue','The SIMD pass scans 32 label bytes at once and identifies weak pixels touching a strong pixel in the 3×3 neighborhood. VPTERNLOGD combines neighbor bits; VPMOVMSKB extracts seed lanes. A queue propagates 255 through 8-connected weak pixels. Its length depends on image content. Scalar queue work has no fixed SIMD peak.')
para(.21,'Parallel boundaries','OpenMP assigns contiguous groups of tiles with static scheduling. After labels are complete, each worker tracks its horizontal slab. Workers collect unresolved weak pixels touching a retained edge across a seam. A final queue completes paths across slabs. The fast queue relies on zero image side columns; top and bottom slab rows still require bounds checks.')
end(3)
def matrix(rect, values, heading, marked=()):
    ax=fig.add_axes(rect)
    nr,nc=len(values),len(values[0])
    ax.set(xlim=(0,nc),ylim=(nr,0))
    ax.axis('off')
    ax.set_title(heading,fontsize=10,color=blue,pad=7,weight='bold')
    for r,row in enumerate(values):
        for c,value in enumerate(row):
            active=(r,c) in marked
            ax.add_patch(plt.Rectangle((c,r),1,1,fc=green if active else '#edf3f6',ec='white',lw=2))
            ax.text(c+.5,r+.5,str(value),ha='center',va='center',fontsize=11,color='white' if active else blue)

page('Follow one pixel through the filters','Worked example • a vertical step from intensity 20 to 60, identical on every row.')
weights=np.exp(-np.arange(-2,3)**2/2)
weights/=weights.sum()
c2,c1=np.rint(weights[:2]*32768).astype(int)
c0=32767-2*(c1+c2)
def gaussian_pass(v):
    return sum((value*coeff+16384)//32768 for value,coeff in
               [(v[2],c0),(v[1]+v[3],c1),(v[0]+v[4],c2)])
def blur_at(x):
    h=gaussian_pass([64*(20 if j<=0 else 60) for j in range(x-2,x+3)])
    return (gaussian_pass([h]*5)+32)//64
xs=list(range(-2,4))
blur=[blur_at(x) for x in xs]
assert blur==[20,22,32,48,58,60]
para(.84,'Gaussian blur spreads the step across nearby columns',
     f'The five horizontal taps at σ = 1 are [{c2}, {c1}, {c0}, {c1}, {c2}] in Q15. The center pixel receives the largest weight. The vertical pass uses the same taps on five filtered rows. Here those rows are identical.')
matrix([.12,.60,.76,.075],[xs,[20,20,20,60,60,60],blur],'Column x  /  input intensity  /  blurred intensity',[(2,2)])
para(.55,'Sobel measures change across the center pixel (x = 0)',
     'Each mask multiplies the blurred patch element by element. Sum the nine products. The right column is brighter than the left, so Gx is positive. The top and bottom rows match, so Gy is zero.')
for x,data,title in [(.08,[blur[1:4]]*3,'Blurred patch'),(.38,[[-1,0,1],[-2,0,2],[-1,0,1]],'Gx weights'),(.68,[[-1,-2,-1],[0,0,0],[1,2,1]],'Gy weights')]:
    matrix([x,.28,.24,.13],data,title,[(1,1)] if x==.08 else [])
para(.23,'What the vector code computes',
     'Each row has D = 48 − 22 = 26 and S = 22 + 2×32 + 48 = 134. Gx = 26 + 2×26 + 26 = 104. Gy = 134 − 134 = 0. The stored magnitude is |104| + |0| = 104. One YMM instruction applies the same operation to 16 adjacent centers.')
end(4)
page('Which pixels become edges?','Continue at the same center pixel • then follow a weak edge across a slab boundary.')
para(.84,'NMS compares along the gradient',
     'At x = 0, |Gy| = 0 and floor(104 × 27146 / 65536) = 43. Because 0 ≤ 43, compare left and right. The center survives when it exceeds the left neighbor and equals or exceeds the right one.')
matrix([.19,.65,.62,.048],[[48,104,104]],'Magnitude at x = −1, 0, +1',[(0,1)])
para(.61,'Double threshold assigns a label',
     '104 > 48 and 104 ≥ 104, so NMS keeps 104. The next center ties its left neighbor and is suppressed. For the surviving center, (104 > 60) + (104 > 120) = 1 + 0 = 1, a weak label. Magnitudes above 120 receive label 2.')
labels=[[2,0,0,0,1],[0,1,0,0,0],[0,0,1,0,0],[0,0,1,0,0]]
edges=[[255 if (r,c) in [(0,0),(1,1),(2,2),(3,2)] else 0 for c in range(5)] for r in range(4)]
path=[(0,0),(1,1),(2,2),(3,2)]
matrix([.08,.285,.38,.16],labels,'Example labels • 2 strong, 1 weak',path)
matrix([.54,.285,.38,.16],edges,'Final edge map • 255 retained',path)
para(.23,'Hysteresis follows all eight neighbor directions',
     'Read this separate label example from the upper left. A strong pixel reaches the first weak pixel diagonally, then the next, then one directly below. All four become 255. The isolated weak pixel at upper right becomes 0. If a slab boundary splits the middle two rows, the seam pass reconnects the same path.')
end(5)
page('What the assembly revealed','Disassembly of the ECE024 binaries, GCC 8.5 with explicit integer SIMD.')
para(.84,'Original Sobel • six vector stack stores','The 10-row × 32-column version kept two independent sets of row differences and sums live. Its compiled loop wrote six YMM temporaries at stack offsets −0x78, −0x58, −0x38, −0x18, +0x08 and +0x28. These are intermediate row-state stores. The count is static and does not estimate stall cycles.')
para(.66,'Tuned Sobel • one group of 16 columns','A single set of row intermediates fits the register file. The audit checks explicit vector operands on RSP/RBP and follows the role of stack references. Gaussian expand, horizontal and vertical row bodies, tuned Sobel and the exact seed scan showed no vector register spill/reload in their main vector path. NMS broadcasts two incoming scalar threshold arguments from positive frame offsets. These are function arguments.')
para(.46,'Scope of the claim','Workers deliberately allocate ring, gradient and label buffers. Tails can stage partial vectors through memory; calls can save scalar registers. The audit supports a hot-loop conclusion. A blanket claim of zero stack accesses across the full application would be incorrect.')
ax=axes([.15,.13,.72,.19])
bars(ax,['1','4','8','16'],[(label,[scaling[str(n),v][0] for n in (1,4,8,16)],c) for label,v,c in [('Two groups','tall',grey),('Single group','onegroup',green)]],'Native 4K frame (ms)')
ax.set_xlabel('Physical cores • original hysteresis queue')
end(6)
page('Find the expensive work first','Cycle sampling guided a second experiment on queue traversal.')
ax=axes([.12,.54,.79,.27])
bars(ax,['Gaussian¹','Sobel','NMS +\nthreshold','Hysteresis²'],[('Native 4K photo',[20.87,6.22,11.24,50.47],blue),('4K noise',[14.76,5.71,8.41,62.21],green)],'User-cycle samples (%)')
fig.text(.09,.47,'¹ Expand, horizontal, vertical and reported tails.  ² Queue kernel and seed scan.\nOther samples include tile orchestration and memory copies.',fontsize=9,color=grey)
para(.38,'Measured before the queue change','One pinned core, perf record on 32 warmed calls, one sample per 250,000 user cycles. The largest symbol was hysteresis_mask_kernel on both inputs. The profiling percentages describe CPU work on one core. Parallel elapsed time includes load imbalance and synchronization.')
para(.20,'Use the border invariant','Each queued pixel already has valid left and right neighbors. Integer division and remainder to recover (y,x) on every pop are unnecessary. Test the linear index against the first and last slab rows, then visit ±1 and the three neighbors in each valid adjacent row. The generic entry point still handles arbitrary boundaries.')
end(7)
page('How performance scales','Physical cores pinned on ECE024 • 1–8 on one socket, 16 across both sockets.')
ax=axes([.13,.52,.77,.29])
for w,label,c in [('1920','1080p portrait',green),('3840','Native 4K Apollo',blue)]:
    vals=[final[w,str(n)][0] for n in cores]
    ax.plot(cores,vals[0]/np.array(vals),'-o',label=label,color=c)
ax.plot(cores,cores,':',color=grey,label='Ideal');ax.set_xticks(cores);ax.set_xlabel('Physical cores');ax.set_ylabel('Speedup over 1 core');ax.legend(frameon=False)
para(.42,'Whole pipeline • native 4K','Median milliseconds at 1, 2, 4, 8 and 16 cores respectively: '+', '.join(f'{final["3840",str(n)][0]:.2f}' for n in cores)+'. The 16-core run crosses NUMA sockets. Input first-touch, changing clock rates, bandwidth and serial seam handling can all affect scaling. Their individual penalties were not isolated.')
para(.24,'Which phase limits the final run?',f'At eight cores on Apollo, filtering through threshold took {final["3840","8"][1]:.2f} ms and hysteresis took {final["3840","8"][2]:.2f} ms. The queue A/B reduced eight-core tracking from 3.04 to 2.10 ms on Apollo and from 4.07 to 2.45 ms on noise. Those A/B medians are from a separate run series. Across-core elapsed time is the relevant metric for the parallel application.')
end(8)
page('Memory layout and kernel size','Unit-stride loads along x; neighbor rows reached by fixed-pitch offsets.')
para(.84,'Keep row-major input and separate local planes','Gaussian and Sobel consume adjacent pixels horizontally. NMS reads magnitudes from three rows but needs directions only at the center. Separate M, Gx and Gy planes allow contiguous vector reads for both patterns. Advancing down a strip reuses source rows before moving to distant pixels.')
para(.65,'Blocking has a measured sweet spot','The earlier eight-core screen on the 1080p portrait tested 128, 256 and 320 columns; 320 minimized filter time in each height/order group. Fewer halos and partial vectors offset the larger working set. Short-block scratch at 320 is 28,480 B. Tall-block scratch is 42,048 B, larger than the 32 KiB L1D. Capacity alone cannot establish residency. Each core has 1 MiB L2.')
para(.44,'Alternatives tested','On a 4K upsampled portrait, full-frame Gaussian intermediates gave 0.486 L1 load misses/pixel. Fused row-major and Morton tile traversal each gave 0.283. The measured layouts both retained row-major pixels within tiles. On native Apollo, switching to one direction byte cut Sobel output from six to three bytes/pixel but changed eight-core time from 5.616 to 5.638 ms. Packing and decoding still cost instructions.')
para(.22,'Reuse versus recomputation','Carrying the two Sobel halo rows reduced a full band from 80 to 66 computed gradient rows. Earlier native 4K timings were 7.603 vs 7.493 ms on eight cores, with a single-core regression. The default recomputes halos. Historical times on the shared host are compared only within their matched experiments.')
end(9)
page('Course methods and evidence','References use PDF page numbers in the supplied 18-645 lecture material.')
para(.84,'Sequential design','Architecture pp. 3, 14 and SIMD pp. 2, 9 motivate work per lane and register capacity. Kernels pp. 6, 9 and Wrapping Up Sequential Design p. 5 connect functional-unit throughput to register lifetimes. Compilers pp. 6–10 motivate testing loop order and unrolling against compiled code. Kernel Design and Benchmarking worksheets supply the resource-bound and work/cycle framework.')
para(.64,'Memory and measurement','Memory Hierarchy pp. 1–2 and Design for Caches pp. 2–7 cover bandwidth, locality, prefetch and blocking. We measured tile widths and region-only cache counters. Additional software prefetch remains untested. Benchmarking Slides and the Welcome speedup example motivate a repeatable baseline and explicit units. Isolated drivers previously reached 37.28 / 48.00 Sobel and 34.74 / 42.24 NMS integer lane-ops/cycle. These separate kernel measurements precede the queue and single-group changes.')
para(.43,'Parallel design','Explicit Parallelism p. 4 and Collective Communications: Loadbalancing p. 2 motivate scaling and choice of schedule. Collective Communications: Cost and Implementation cover scatter, gather and communication volume. A prior two-rank × four-thread single-host test took 25.077 ms vs 6.765 ms with eight OpenMP threads on Apollo. MPI gathered labels for one-thread tracking. That comparison includes both communication and tracking policy. Block-cyclic scheduling and multi-host MPI remain open experiments.')
para(.19,'Reproduce and interpret','Use make fusion on ECE024. benchmarks/fusion/audit contains raw trials, profiles and the two experimental patches. Final timings include all processing and workspace setup; the scalar baseline uses the same algorithm and includes full-frame allocation. Measured on a shared host. The phase and register conclusions apply to these binaries, inputs and placements.')
end(10)
pdf.close()
