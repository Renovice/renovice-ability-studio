from pathlib import Path
import json,subprocess
r=Path(r'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE');e=r/'repos/apps/ability-editor';out=e/'RESEARCH/CARD_VALUE_LABELS_2026-09-27/artifacts';cli=r/'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe';files=[p for p in (r/'work/rendered-source/ability-editor').glob('*.luau') if p.stem.count('.')==0];files.append(e/'RESEARCH/U44_AUTHORING_2026-09-27/artifacts/globe.readable.luau')
results=[]
for p in files:
 q=subprocess.run([str(cli),'card-stats','--source',str(p),'--body-key',p.stem,'--names',str(r/'work/catalogs/Names.en.json')],capture_output=True,text=True,encoding='utf-8');assert q.returncode==0,q.stderr
 d=json.loads(q.stdout);rows=d['rows'];mapped=[x for x in rows if x['inputs']];results.append({'file':str(p),'rows':len(rows),'mapped':len(mapped),'labels':[x['label'] for x in mapped]});(out/(p.stem+'.cards.json')).write_text(q.stdout,encoding='utf-8')
print(json.dumps(results,indent=2));(out/'coverage.json').write_text(json.dumps(results,indent=2))
