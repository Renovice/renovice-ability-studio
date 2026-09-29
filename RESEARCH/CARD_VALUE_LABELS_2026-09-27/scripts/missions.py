from pathlib import Path
import runpy, subprocess, json
r=Path(r'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE');e=r/'repos/apps/ability-editor';out=e/'RESEARCH/CARD_VALUE_LABELS_2026-09-27/artifacts';out.mkdir(exist_ok=True)
c=runpy.run_path(str(r/'archive/legacy-decompilers/transpiler-lab/cache_extract.py'));original=c['oodle_decompress'];c['extract'].__globals__['oodle_decompress']=lambda d,n:bytes(d) if len(d)==n else original(d,n)
toc=Path(r'C:\Program Files (x86)\Steam\steamapps\common\Warframe\Cache.Windows\B.Font.toc');es=c['toc_decode'](toc.read_bytes());ps=c['build_paths'](es)
normalize=runpy.run_path(str(e/'RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py'))['normalize']
compiler=r/'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
for target in ['/Lotus/Scripts/Modes/EntratiVoidVaults.lua','/Lotus/Scripts/Modes/Purgatory.lua']:
 i=ps.index(target);b=c['extract'](toc,target,*es[i][:3]);name=target.rsplit('/',1)[1];raw=out/(name+'_B');raw.write_bytes(b);canon=out/(name+'.canonical');canon.write_bytes(normalize(b))
 args=[str(compiler),'semantic-ir-render-module-readable',str(canon),str(out/(name+'.fidelity.luau')),str(out/(name+'.readable.luau')),str(out/(name+'.names.json')),'--semantic-sdk',str(r/'shared/semantic-sdk/symbols.tsv')]
 p=subprocess.run(args,capture_output=True,text=True);(out/(name+'.render.log')).write_text(p.stdout+p.stderr);print(name,p.returncode,(p.stdout+p.stderr)[-700:])
