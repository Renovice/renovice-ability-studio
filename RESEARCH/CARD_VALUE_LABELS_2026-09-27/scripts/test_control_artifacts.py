"""Offline checks; no live installation or gameplay claim."""
from pathlib import Path
import json, runpy, subprocess, struct
editor=Path(__file__).resolve().parents[3]; root=editor.parents[2]
out=Path(__file__).resolve().parents[1]/'artifacts/control-tests';out.mkdir(exist_ok=True)
compiler=root/'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
cli=root/'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'
logs=editor/'RESEARCH/U44_AUTHORING_2026-09-27/artifacts/profile-tests'
profile=json.loads((editor/'REGISTRIES/mission_build_u44.json').read_text())
def manifest(ident):
    path=next(line[10:] for line in (logs/(ident+'.log')).read_text().splitlines() if line.startswith('Manifest: '))
    p=Path(path);return p.parent,json.loads(p.read_text())
for ident,number in [('netracells',2),('descendia_shrine',15)]:
    folder,m=manifest(ident);b=profile['missions'][ident]['metadata']
    actual=(folder/m['artifact']['path']).read_text()
    assert actual==f"{b['owner']}\n    q|{b['field']}|{number}\n"
    assert m['package_type']=='METADATA_PATCH' and m['intended_live_relative_path']==f'OpenWF/Metadata Patches/{ident}.txt'
    print('PASS exact metadata output',ident)
folder,m=manifest('descendia_excavation');raw=(folder/m['artifact']['path']).read_bytes()
rec=profile['missions']['descendia_excavation'];stock=(root/profile['corpus']/rec['file']).read_bytes()
allowed={p['offset']+i for p in rec['patches'] for i in range(len(p['expected']))}
assert len(raw)==len(stock) and all(a==b or i in allowed for i,(a,b) in enumerate(zip(raw,stock)))
assert struct.unpack_from('<d',raw,22618)[0]==15 and struct.unpack_from('<h',raw,21002)[0]==15
normalizer=runpy.run_path(str(editor/'RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py'))['normalize']
canonical=out/'descendia.canonical.lua_B';canonical.write_bytes(normalizer(raw))
render=out/'descendia.readable.luau'
r=subprocess.run([str(compiler),'semantic-ir-render-module-readable',str(canonical),str(out/'descendia.fidelity.luau'),str(render),str(out/'descendia.names.json'),'--semantic-sdk',str(root/'shared/semantic-sdk/symbols.tsv')],capture_output=True,text=True)
assert r.returncode==0,r.stderr
original=(out.parent/'CoHExcavationLite.lua.readable.luau').read_text().splitlines()
changed=render.read_text().splitlines()
assert len(original)==len(changed)
diff=[(i+1,a,b) for i,(a,b) in enumerate(zip(original,changed)) if a!=b]
assert len(diff)==5 and all(a.replace('45','15')==b for _,a,b in diff),diff
(out/'descendia-source-diff.json').write_text(json.dumps(diff,indent=2))
print('PASS all five linked Descendia consumers; no other source or bytecode changes')
source=root/'work/rendered-source/ability-editor/dc33836ea5685c89.luau'
r=subprocess.run([str(cli),'card-stats','--source',str(source),'--body-key','dc33836ea5685c89','--names',str(root/'work/catalogs/Names.en.json'),'--editor-root',str(editor)],capture_output=True,text=True,encoding='utf-8')
assert r.returncode==0,r.stderr
d=json.loads(r.stdout);b=source.read_bytes();control=next(c for c in d['controls'] if c['id']=='v18_7.rank4')
for inp in sorted(control['inputs'],key=lambda i:i['offset'],reverse=True):
    start=inp['offset'];end=start+inp['length'];assert b[start:end]==b'30000';b=b[:start]+b'40000'+b[end:]
edited=out/'dagath-linked-damage.luau';edited.write_bytes(b)
binary=out/'dagath-linked-damage.lua_B'
for name,args,marker in [('compile',['recompile',str(edited),str(binary)],'re-parses=yes'),('plan',['plan-verify',str(binary)],'failures=0'),('container',['de-roundtrip',str(binary)],'FULL BODY identical: True')]:
    p=subprocess.run([str(compiler),*args],capture_output=True,text=True,encoding='utf-8');(out/(name+'.log')).write_text(p.stdout+p.stderr,encoding='utf-8');assert p.returncode==0 and marker in p.stdout,(name,p.stdout,p.stderr)
print('PASS linked gameplay/card source compile, all-prototype plan verification and container roundtrip')
