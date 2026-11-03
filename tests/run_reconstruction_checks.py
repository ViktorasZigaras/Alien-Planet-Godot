"""Run original regression families plus reconstruction integration checks.
Usage: python3 tests/run_reconstruction_checks.py --godot /path/to/godot
"""
from pathlib import Path
import argparse,json,os,shutil,subprocess,sys,time
parser=argparse.ArgumentParser();parser.add_argument('--godot',default=os.environ.get('GODOT_BIN') or shutil.which('godot') or shutil.which('godot4'));args=parser.parse_args()
if not args.godot:parser.error('Pass --godot or set GODOT_BIN.')
root=Path(__file__).resolve().parents[1];out=root/'reports/reconstruction';out.mkdir(parents=True,exist_ok=True)
suites=['test_batch','test_batch_ui','test_0901','test_0903','test_0904','test_frontier','test_model_lab','test_visual_style','test_world','test_reconstruction','reconstruction_ui','test_0902']
results=[]
for suite in suites:
 started=time.monotonic()
 try:
  result=subprocess.run([args.godot,'--headless','--path',str(root),'--script','tests/'+suite+'.gd'],cwd=root,capture_output=True,text=True,timeout=600)
  text=result.stdout+result.stderr
  failed=result.returncode!=0 or 'SCRIPT ERROR:' in text or '\nERROR:' in text or '\nFAIL' in text
  row={'suite':suite,'exit':result.returncode,'passed':not failed,'seconds':round(time.monotonic()-started,2),'tail':text[-1800:]}
 except subprocess.TimeoutExpired as error:
  text=(error.stdout or b'').decode(errors='replace')+(error.stderr or b'').decode(errors='replace')
  row={'suite':suite,'exit':'timeout','passed':False,'seconds':600,'tail':text[-1800:]}
 (out/(suite+'.log')).write_text(text)
 results.append(row);(out/'regression_results.json').write_text(json.dumps(results,indent=2))
 print(json.dumps(row),flush=True)
sys.exit(0 if all(r['passed'] for r in results) else 1)
