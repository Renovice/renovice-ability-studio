"""Inspect/register exact stock ConquestLib wave configuration assignments."""
from pathlib import Path
import json, sys, struct, hashlib
editor=Path(__file__).resolve().parents[3];root=editor.parents[2]
out=Path(__file__).resolve().parents[1]/'artifacts'
sys.path.insert(0,str(root/'archive/legacy-decompilers/transpiler-lab'))
import _flat_loader as F, parse_luab as P
name='Lotus_Scripts_Libs_ConquestLib.lua_B'
raw=(out/name).read_bytes();b=(out/'Lotus_Scripts_Libs_ConquestLib.lua.canonical').read_bytes()
pool,_,_=F.parse_pool_and_nps(b);_,es=F.load_flat(b);pi=len(es)-1
co,ln,_=F.header_at(b,es[pi][0]);_,ks,_=P.parse_consts(b,co+ln)
wide={int(x,16) for x in '02 03 0c 0f 15 17 1c 1e 20 21 23 26 27 2c 2d 33 34 36 37 3a 3d 3f 41 43 46 4a'.split()}
ins=[];off=co
while off<co+ln:
    width=8 if b[off] in wide else 4;ins.append((off,b[off:off+width]));off+=width
def keyname(word):
    if len(word)==8:
        k=struct.unpack_from('<I',word,4)[0]
        if k<len(ks) and ks[k][0]=='str':return pool[ks[k][1]-1].decode()
    return ''
sites=[i for i,(_,word) in enumerate(ins) if keyname(word)=='waveOverrides' and word[0]==0x15]
assert len(sites)==2,sites
for site in sites:
    print('waveOverrides',site)
    for i in range(site-12,site+2):
        off,word=ins[i];print(i,off,word.hex(),keyname(word))

if '--register' in sys.argv:
    expected_sha='f66902986b5e5b8f46ed460c8dab1ff576a336c7464e7637813c62bf24620fa5'
    assert hashlib.sha256(raw).hexdigest()==expected_sha
    specs=[(1010,2,10,'eta_survival_minutes'),(1013,8,6,'eta_defense_waves'),
           (1038,2,10,'eda_survival_minutes'),(1041,8,4,'eda_mirror_defenses'),
           (1044,38,2,'eda_alchemy_mixtures'),(1047,33,8,'eda_disruption_conduits')]
    patches=[]
    for ii,mission_type,stock,param in specs:
        off,word=ins[ii];before=ins[ii-1][1];after=ins[ii+1][1]
        assert word[0]==0x12 and word[1]==9 and struct.unpack_from('<h',word,2)[0]==stock
        assert before[0]==0x12 and before[1]==8 and struct.unpack_from('<h',before,2)[0]==mission_type
        assert after==bytes.fromhex('2a090708') and raw[off]==8
        patches.append(dict(prototype=pi,instruction=ii,offset=off,expected=list(raw[off:off+4]),register=9,
                            value=param,numerator=1,denominator=1,owner=param))
    n=1469598103934665603
    for byte in raw:n=((n^byte)*1099511628211)&0xffffffffffffffff
    record=dict(body_key=f'{n:016x}',file=name,sha256=expected_sha.upper(),module_path='Lotus.Scripts.Libs.ConquestLib',patches=patches,
                parameters={param:dict(minimum=1,maximum=60 if 'minutes' in param else stock) for _,_,stock,param in specs})
    profile_path=editor/'REGISTRIES/mission_build_u44.json';profile=json.loads(profile_path.read_text())
    profile['missions']['archimedea']=record
    profile_path.write_text(json.dumps(profile,indent=2)+'\n')
    (root/profile['corpus']/name).write_bytes(raw)
    (out/'bindings.json').write_text(json.dumps(record,indent=2)+'\n')
    print('Registered six Archimedea parameters',record['body_key'])
