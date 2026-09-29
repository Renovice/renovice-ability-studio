from pathlib import Path
import json,re,runpy,sys
r=Path(r'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE');a=r/'work/rendered-source/ability-editor'
fs=list(a.glob('*.luau'));fs=[p for p in fs if p.stem.count('.')==0]
print('rendered modules',len(fs))
rows=[]
for p in fs:
 s=p.read_text(encoding='utf-8-sig');n=len(re.findall(r'Label = "[^"]+", Value =',s))
 if n:rows.append((p.stem,n))
print('with card-like numeric rows',len(rows),'rows',sum(n for _,n in rows))
sys.path.insert(0,str(r/'archive/legacy-decompilers/transpiler-lab'))
c=runpy.run_path(str(r/'archive/legacy-decompilers/transpiler-lab/cache_extract.py'))
toc=Path(r'C:\Program Files (x86)\Steam\steamapps\common\Warframe\Cache.Windows\B.Font.toc');es=c['toc_decode'](toc.read_bytes());ps=c['build_paths'](es)
for i,p in enumerate(ps):
 if p.endswith('.lua') and any(x in p.lower() for x in ['descent','descend','netracell','voidvault','purgatory']):print(p)
