"""Offline current-cache inspection. Does not write game files."""
from pathlib import Path
import runpy, subprocess, json, re, sys, hashlib
editor=Path(__file__).resolve().parents[3];root=editor.parents[2]
out=Path(__file__).resolve().parents[1]/'artifacts';out.mkdir(parents=True,exist_ok=True)
cache=runpy.run_path(str(root/'archive/legacy-decompilers/transpiler-lab/cache_extract.py'))
original=cache['oodle_decompress']
cache['extract'].__globals__['oodle_decompress']=lambda d,n:bytes(d) if len(d)==n else original(d,n)
toc=Path(r'C:\Program Files (x86)\Steam\steamapps\common\Warframe\Cache.Windows\B.Font.toc')
entries=cache['toc_decode'](toc.read_bytes());paths=cache['build_paths'](entries)
pattern=sys.argv[1] if len(sys.argv)>1 else r'Archimedea|Conquest'
matches=[(i,p) for i,p in enumerate(paths) if p.endswith('.lua') and re.search(pattern,p,re.I)]
if '--list' in sys.argv:
    print('\n'.join(p for _,p in matches));sys.exit(0)
normalize=runpy.run_path(str(editor/'RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py'))['normalize']
compiler=root/'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
for i,path in matches:
    name=path.strip('/').replace('/','_');raw=out/(name+'_B')
    data=cache['extract'](toc,path,*entries[i][:3]);raw.write_bytes(data)
    canonical=out/(name+'.canonical');canonical.write_bytes(normalize(data))
    result=subprocess.run([str(compiler),'semantic-ir-render-module-readable',str(canonical),str(out/(name+'.fidelity.luau')),str(out/(name+'.readable.luau')),str(out/(name+'.names.tsv')),'--semantic-sdk',str(root/'shared/semantic-sdk/symbols.tsv')],capture_output=True,text=True,encoding='utf-8')
    (out/(name+'.render.log')).write_text(result.stdout+result.stderr,encoding='utf-8')
    print(path,hashlib.sha256(data).hexdigest(),result.returncode,flush=True)
    assert result.returncode==0,result.stderr
