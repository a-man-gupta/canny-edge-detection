import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
import cv2
import numpy as np
from generate_dataset import synthetic
from run import ROOT, metrics, validate


class BenchmarkTests(unittest.TestCase):
    def test_metrics_empty_and_mismatch(self):
        empty=np.zeros((2,2),np.uint8)
        self.assertEqual(metrics(empty,empty)['f1'],1)
        single=empty.copy();single[0,0]=255
        self.assertEqual(metrics(single,empty)['f1'],0)
        self.assertEqual(metrics(empty,single)['recall'],0)
        self.assertEqual(metrics(single,single)['agreement_pct'],100)

    def test_large_sparse_self_comparison(self):
        # Exercises vectorized paths absent in tiny fixtures, including boolean complements.
        image=np.zeros((480,640),np.uint8)
        image[10:400:3,100:500:7]=255
        result=metrics(image,image)
        self.assertEqual(result['f1'],1)
        self.assertEqual(result['agreement_pct'],100)
        self.assertEqual(result['fp'],0)
        self.assertEqual(result['fn'],0)
        self.assertAlmostEqual(result['edge_density'],np.count_nonzero(image)/image.size)

    def test_invalid_adapter_result(self):
        image=np.zeros((2,2),np.uint8)
        with self.assertRaises(ValueError):
            validate({'samples':[{'compute_ms':float('nan'),'e2e_ms':1}]},1,image.shape,image)
        with self.assertRaises(ValueError):
            validate({'samples':[{'compute_ms':1,'e2e_ms':1}]},2,image.shape,image)
        with self.assertRaises(ValueError):
            validate({'samples':[{'compute_ms':1,'e2e_ms':1}]},1,image.shape,np.ones((2,2),np.uint8))

    def test_seeded_fixtures(self):
        a=synthetic('noise',96,64,18645)
        self.assertTrue(np.array_equal(a,synthetic('noise',96,64,18645)))
        self.assertFalse(np.array_equal(a,synthetic('noise',96,64,1)))

    @unittest.skipUnless((ROOT/'build/canny_scalar').exists(),'build scalar executable first')
    def test_scalar_and_runner_failure_handling(self):
        with tempfile.TemporaryDirectory() as directory:
            tmp=Path(directory)
            # Independently understood input: an intensity step, with no noise.
            image=np.zeros((64,96),np.uint8);image[:,48:]=255
            cv2.imwrite(str(tmp/'step.pgm'),image)
            cmd=[str(ROOT/'build/canny_scalar'),'--input',str(tmp/'step.pgm'),'--output',str(tmp/'edge.pgm'),
                 '--iterations','3','--warmup','2','--low','50','--high','100','--sigma','1.4']
            result=subprocess.run(cmd,capture_output=True,text=True,check=True)
            output=cv2.imread(str(tmp/'edge.pgm'),0)
            validate(json.loads(result.stdout),3,image.shape,output)
            ys,xs=np.where(output)
            self.assertGreater(len(ys),50)
            self.assertTrue(np.all((xs>=46)&(xs<=49)))
            subprocess.run([sys.executable,str(ROOT/'benchmarks/generate_dataset.py'),'--smoke','--output',str(tmp/'data')],check=True,capture_output=True)
            (tmp/'adapters.json').write_text(json.dumps({'broken':['/nonexistent/canny']}))
            run=subprocess.run([sys.executable,str(ROOT/'benchmarks/run.py'),'--manifest',str(tmp/'data/manifest.json'),
                                '--output',str(tmp/'run'),'--iterations','2','--warmup','1','--case','sanity_blank',
                                '--adapters',str(tmp/'adapters.json'),'--implementations','scalar','broken','opencv-1'],capture_output=True,text=True)
            self.assertEqual(run.returncode,1,run.stderr)
            statuses=json.loads((tmp/'run/status.json').read_text())
            self.assertEqual([r['status'] for r in statuses],['ok','failed','ok'])
            edges=cv2.imread(str(tmp/'run/edges/sanity_blank_0.pgm'),0)
            self.assertEqual(np.count_nonzero(edges),0)


if __name__=='__main__':
    unittest.main()
