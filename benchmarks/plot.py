#!/usr/bin/env python3
"""Render measured data; never synthesize timings for missing stages."""
import argparse
import csv
import json
from pathlib import Path
import os
import tempfile
_plot_cache = tempfile.TemporaryDirectory(prefix="canny-matplotlib-")
os.environ.setdefault("MPLCONFIGDIR", _plot_cache.name)
os.environ.setdefault("XDG_CACHE_HOME", _plot_cache.name)
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from run import STAGES, write_csv


def read(path):
    with path.open(newline='') as f:
        return list(csv.DictReader(f))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('results', type=Path)
    p.add_argument('--traffic-model', type=Path, help='Optional JSON of logical bytes per pixel for a measured stage')
    a = p.parse_args()
    summary, raw = read(a.results/'summary.csv'), read(a.results/'raw.csv')
    out = a.results/'plots';out.mkdir(exist_ok=True)
    implementations = list(dict.fromkeys(r['implementation'] for r in summary))

    # Throughput against image size, from the median latency of the resolution sweep.
    for basis in ['compute','e2e']:
        fig, ax = plt.subplots(figsize=(9,5))
        for name in implementations:
            rows = sorted([r for r in summary if r['implementation']==name and r['axis']=='resolution'],key=lambda r:int(r['width'])*int(r['height']))
            if rows:
                ax.plot([int(r['width'])*int(r['height'])/1e6 for r in rows], [float(r[f'{basis}_mpix_s']) for r in rows], 'o-', label=name)
        ax.set(xlabel='Image size (MP)',ylabel='Throughput (MP/s)',title=f'{basis}: throughput from median latency')
        if ax.lines: ax.legend()
        ax.grid(alpha=.2);fig.tight_layout();fig.savefig(out/f'throughput_{basis}.png',dpi=160);plt.close(fig)

    # One stage chart and one latency chart per case.
    for case in dict.fromkeys(r['case'] for r in summary):
        rows = [r for r in summary if r['case']==case]
        names = [r['implementation'] for r in rows]
        x=np.arange(len(rows));bottom=np.zeros(len(rows))
        fig, ax = plt.subplots(figsize=(max(8,len(rows)*1.5),5))
        for stage in STAGES:
            values=[]; available=False
            for row in rows:
                values_for_stage=[float(r[stage]) for r in raw if r['case']==case and r['implementation']==row['implementation'] and r.get(stage,'')!='']
                available |= bool(values_for_stage)
                values.append(np.mean(values_for_stage) if values_for_stage else 0)
            if available:
                ax.bar(x,values,bottom=bottom,label=stage.removesuffix('_ms'));bottom+=values
        ax.set(xticks=x,xticklabels=names,ylabel='Mean measured stage time (ms)',title=f'{case}: stage breakdown (absent stages unreported)')
        ax.tick_params(axis='x',rotation=20);ax.legend(fontsize=8);fig.tight_layout();fig.savefig(out/f'{case}_stages.png',dpi=160);plt.close(fig)
        fig, ax = plt.subplots(figsize=(max(8,len(rows)*1.5),5))
        for offset,basis in [(-.18,'compute'),(.18,'e2e')]:
            med=np.array([float(r[f'{basis}_ms_median']) for r in rows]);p95=np.array([float(r[f'{basis}_ms_p95']) for r in rows])
            ax.bar(x+offset,med,.35,label=f'{basis} median')
            ax.errorbar(x+offset,med,yerr=[np.zeros(len(rows)),p95-med],fmt='none',ecolor='black',capsize=3)
        ax.set(xticks=x,xticklabels=names,ylabel='Latency (ms)',title=f'{case}: median with upper whisker at p95')
        ax.tick_params(axis='x',rotation=20);ax.legend();fig.tight_layout();fig.savefig(out/f'{case}_latency.png',dpi=160);plt.close(fig)

    # Optional logical-byte table. Unused unless the caller passes a model file.
    bandwidth=[]
    if a.traffic_model:
        model=json.loads(a.traffic_model.read_text())
        (out/'traffic_model.json').write_text(json.dumps(model,indent=2)+'\n')
        for row in summary:
            spec=model.get(row['implementation'])
            if not spec: continue
            for stage, traffic in spec['stages'].items():
                latency=row.get(stage+'_median','')
                if not latency: continue
                bpp=float(traffic['bytes_per_pixel'])
                if not np.isfinite(bpp) or bpp<=0 or not traffic.get('rationale'):
                    raise ValueError('Traffic requires positive bytes_per_pixel and rationale')
                gbs=bpp*int(row['width'])*int(row['height'])/float(latency)/1e6
                # Logical bytes over measured time. Not a hardware-counter reading.
                bw={'case':row['case'],'implementation':row['implementation'],'stage':stage,
                    'logical_bytes_per_pixel':bpp,'effective_logical_gbs':gbs,'rationale':traffic['rationale']}
                bandwidth.append(bw)
        write_csv(out/'bandwidth_model.csv',bandwidth)
    accuracy=read(a.results/'accuracy.csv')
    # Portable HTML table for review/presentation; image files remain standalone.
    import html
    fields=['case','implementation','reference','agreement_pct','f1','precision','recall','edge_density']
    table='<table border="1"><tr>'+''.join(f'<th>{k}</th>' for k in fields)+'</tr>'
    for row in accuracy:
        table+='<tr>'+''.join(f'<td>{html.escape(row[k])}</td>' for k in fields)+'</tr>'
    report='<!doctype html><meta charset="utf-8"><title>Canny benchmark</title><h1>Measured benchmark results</h1>'
    report+='<p>Stage bars use means for additivity. Latency bars use medians and p95. Missing stages have no measured segment. OpenCV Canny is an opaque aggregate. Bandwidth models are logical traffic estimates, not DRAM counter measurements.</p>'
    report+=table+'</table>'
    for path in sorted(out.glob('*.png')):
        report+=f'<p><img style="max-width:100%" src="{html.escape(path.name)}" alt="{html.escape(path.stem)}"></p>'
    (out/'index.html').write_text(report)
    (out/'plot_metadata.json').write_text(json.dumps({'traffic_model':str(a.traffic_model) if a.traffic_model else None},indent=2)+'\n')
    print(f'Plots and accuracy table: {out}/index.html')
    if bandwidth:
        print(f'Logical traffic table: {out}/bandwidth_model.csv')


if __name__ == '__main__':
    main()
