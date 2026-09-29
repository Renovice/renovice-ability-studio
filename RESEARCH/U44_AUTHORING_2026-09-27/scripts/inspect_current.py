from pathlib import Path
import sys,json,runpy
root=Path(r'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE')
out=root/'repos/apps/ability-editor/RESEARCH/U44_AUTHORING_2026-09-27/artifacts'
sys.path.insert(0,str(root/'archive/legacy-decompilers/transpiler-lab'))
import _flat_loader as F
m=json.loads((root/'work/research/U44-2026-09-27/lua-port/artifacts/native-dispatch-map.json').read_text())['map'];inv={int(v):int(k) for k,v in m.items()}
wide={int(x,16) for x in '02 03 0c 0f 15 17 1c 1e 20 21 23 26 27 2c 2d 33 34 36 37 3a 3d 3f 41 43 46 4a'.split()}
def normalize(b):
 b=bytearray(b);_,es=F.load_flat(b)
 for ph,*_ in es:
  co,ln,_=F.header_at(b,ph);off=co
  while off<co+ln:
   op=inv[b[off]];b[off]=op;off+=8 if op in wide else 4
  assert off==co+ln
 return b
if __name__=='__main__':
 b=(root/'work/research/U44-2026-09-27/lua-port/artifacts/Lotus_Powersuits_Bard_Abilities_BardMusic.lua_B').read_bytes()
 (out/'mallet.opcodes-only.lua_B').write_bytes(normalize(b))
 c=runpy.run_path(str(root/'archive/legacy-decompilers/transpiler-lab/cache_extract.py'));orig=c['oodle_decompress'];c['extract'].__globals__['oodle_decompress']=lambda d,n:bytes(d) if len(d)==n else orig(d,n)
 toc=Path(r'C:\Program Files (x86)\Steam\steamapps\common\Warframe\Cache.Windows\B.Font.toc');entries=c['toc_decode'](toc.read_bytes());paths=c['build_paths'](entries)
 for i,path in enumerate(paths):
  if path.endswith('.lua') and any(x in path.lower() for x in ['zarimansurvival','iceglobe','snowglobe','icewave','frost/abilities/iceshield','frost/abilities/icespike']):
   b=c['extract'](toc,path,*entries[i][:3]);name=path.strip('/').replace('/','_')+'_B';(out/name).write_bytes(b);(out/(name+'.canonical')).write_bytes(normalize(b));print(path,name)


