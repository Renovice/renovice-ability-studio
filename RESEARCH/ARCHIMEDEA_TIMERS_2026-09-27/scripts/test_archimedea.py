"""Offline profile acceptance, source diffs and isolated field edits."""
from pathlib import Path
import copy, json, subprocess, runpy, struct
editor=Path(__file__).resolve().parents[3];root=editor.parents[2]
out=Path(__file__).resolve().parents[1]/'artifacts/tests';out.mkdir(exist_ok=True)
cli=root/'work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe'
compiler=root/'repos/toolchains/de-luau-toolchain/bin/derecomp.exe'
profile=json.loads((editor/'REGISTRIES/mission_build_u44.json').read_text());record=profile['missions']['archimedea']
stock=(root/profile['corpus']/record['file']).read_bytes()
normalize=runpy.run_path(str(editor/'RESEARCH/U44_AUTHORING_2026-09-27/scripts/inspect_current.py'))['normalize']
base=json.loads((editor/'RESEARCH/U44_AUTHORING_2026-09-27/artifacts/profile-tests/archimedea.json').read_text())
stock_values={p['value']:struct.unpack('<h',bytes(p['expected'][2:]))[0] for p in record['patches']}
faster=dict(eta_survival_minutes=5,eta_defense_waves=3,eda_survival_minutes=5,eda_mirror_defenses=2,eda_alchemy_mixtures=1,eda_disruption_conduits=4)
cases={'stock':stock_values,'faster':faster}
for key in faster:cases[key]={**stock_values,key:faster[key]}
def invoke(args):
    r=subprocess.run([str(cli),*args,'--editor-root',str(editor)],capture_output=True,text=True,encoding='utf-8')
    return r
for name,values in cases.items():
    project=copy.deepcopy(base);project['id']='mission.archimedea.'+name;project['mission_profile']['values']=values
    path=out/(name+'.json');path.write_text(json.dumps(project,indent=2))
    r=invoke(['build',str(path),'--staging',str(root/'work/staging/archimedea-acceptance')]);(out/(name+'.log')).write_text(r.stdout+r.stderr)
    assert r.returncode==0,(name,r.stdout,r.stderr)
    manifest_path=Path(next(l[10:] for l in r.stdout.splitlines() if l.startswith('Manifest: ')))
    manifest=json.loads(manifest_path.read_text());artifact=manifest_path.parent/manifest['artifact']['path']
    actual=artifact.read_bytes();expected=bytearray(stock)
    for patch in record['patches']:struct.pack_into('<h',expected,patch['offset']+2,values[patch['value']])
    assert actual==expected,'Unexpected change outside the six native assignments'
    assert manifest['package_type']=='NATIVE_REPLACEMENT' and '/Inject/' not in manifest['intended_live_relative_path']
    assert all(g['pass'] for g in manifest['gates']) and manifest['live_write_performed'] is False
    if name=='stock':assert actual==stock
    if name=='faster':
        canonical=out/'faster.canonical';canonical.write_bytes(normalize(actual))
        for tag,args,marker in [('plan',['plan-verify',str(canonical)],'failures=0'),
            ('render',['semantic-ir-render-module-readable',str(canonical),str(out/'faster.fidelity.luau'),str(out/'faster.readable.luau'),str(out/'faster.names.tsv'),'--semantic-sdk',str(root/'shared/semantic-sdk/symbols.tsv')],None)]:
            rr=subprocess.run([str(compiler),*args],capture_output=True,text=True,encoding='utf-8');(out/(tag+'.log')).write_text(rr.stdout+rr.stderr)
            assert rr.returncode==0 and (marker is None or marker in rr.stdout),(tag,rr.stdout,rr.stderr)
        original=(out.parent/'Lotus_Scripts_Libs_ConquestLib.lua.readable.luau').read_text().splitlines()
        rendered=(out/'faster.readable.luau').read_text().splitlines();assert len(rendered)==len(original)
        differences=[(i+1,a,b) for i,(a,b) in enumerate(zip(original,rendered)) if a!=b]
        assert len(differences)==6,differences
        assert {a.strip() for _,a,_ in differences}=={'frame_43[764][2] = 10','frame_43[764][8] = 6','frame_43[782][2] = 10','frame_43[782][8] = 4','frame_43[782][38] = 2','frame_43[782][33] = 8'}
        (out/'source-diff.json').write_text(json.dumps(differences,indent=2))
    print('PASS',name,flush=True)
for key in faster:
    for value in [0,1.5,record['parameters'][key]['maximum']+1]:
        project=copy.deepcopy(base);project['mission_profile']['values']={**stock_values,key:value}
        path=out/'invalid.json';path.write_text(json.dumps(project))
        assert invoke(['validate',str(path)]).returncode!=0,(key,value)
print('PASS eight exports, six isolated controls, source/plan checks, and 18 invalid values')
