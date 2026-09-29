from pathlib import Path
import json,sys,struct,runpy,hashlib
root=Path(r'C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE');editor=root/'repos/apps/ability-editor';out=editor/'RESEARCH/U44_AUTHORING_2026-09-27';port=root/'work/research/U44-2026-09-27/lua-port/artifacts'
sys.path.insert(0,str(root/'archive/legacy-decompilers/transpiler-lab'));import _flat_loader as F,parse_luab as P
normalize=runpy.run_path(str(out/'scripts/inspect_current.py'))['normalize']
wide={int(x,16) for x in '02 03 0c 0f 15 17 1c 1e 20 21 23 26 27 2c 2d 33 34 36 37 3a 3d 3f 41 43 46 4a'.split()}
def key(b):
 n=1469598103934665603
 for x in b:n=((n^x)*1099511628211)&0xffffffffffffffff
 return f'{n:016x}'
def proto(b,p):
 _,es=F.load_flat(b);co,ln,_=F.header_at(b,es[p][0]);_,ks,_=P.parse_consts(b,co+ln);off=co;ins=[]
 while off<co+ln:
  w=8 if b[off] in wide else 4;ins.append((off,bytes(b[off:off+w])));off+=w
 return ins,ks
spec={
 'mobile_defense':('89329f85c8575b84',[(22,120,'minimum_total_time',1,1),(22,121,'maximum_total_time',1,1)]),
 'excavation':('303f809a05c1fbaa',[(49,76,'standard_dig_time',1,1),(32,81,'old_world_salvage_dig_time',1,1),(32,102,'elite_alert_dig_time',1,1)]),
 'control_area_plains':('bf3c901cb4058c47',[(17,44,'control_area_duration',1,1),(8,100,'control_area_duration',1,1)]),
 'control_area_deimos':('d9541341dfd466a3',[(15,56,'control_area_duration',1,1),(7,63,'control_area_duration',1,1)]),
 'control_area_nokko':('e192d5cc2f37056e',[(6,112,'control_area_duration',2,3),(6,107,'control_area_duration',1,2),(5,118,'control_area_duration',1,1)]),
 'survival':('1e3647332a578b78',[]),'interception':('a51e98a1833bd8c1',[])}
targets={t['oldKey']:t for t in json.loads((port/'targets.json').read_text())};changes={r['file'][:16]:r for r in json.loads((port/'replacement-rebase.json').read_text())};records={}
corpus=root/'shared/corpus/de-luau-u44-authoring';corpus.mkdir(exist_ok=True)
for ident,(old,sites) in spec.items():
 t=targets[old];b=(port/t['file']).read_bytes();canonical=normalize(b);(corpus/t['file']).write_bytes(b)
 record={'legacy_body_key':old,'body_key':key(b),'file':t['file'],'sha256':hashlib.sha256(b).hexdigest().upper(),'module_path':t['path'].strip('/').removesuffix('.lua').replace('/','.'),'patches':[]}
 for pi,ii,field,num,den in sites:
  change=next(x for x in changes[old]['edits'] if x['prototype']==pi and x['oldInstruction']==ii);ni=change['newInstruction'];ins,_=proto(canonical,pi);off,word=ins[ni];assert len(word)==4
  assert b[off:off+4].hex()==change['old']
  record['patches'].append({'prototype':pi,'instruction':ni,'offset':off,'expected':list(b[off:off+4]),'register':bytes.fromhex(change['new'])[1],'value':field,'numerator':num,'denominator':den})
 records[ident]=record
name='Lotus_Scripts_Modes_ZarimanSurvivalMission.lua_B';b=(out/'artifacts'/name).read_bytes();canonical=normalize(b);(corpus/name).write_bytes(b);pool,_,_=F.parse_pool_and_nps(b);_,es=F.load_flat(b);pi=len(es)-1;ins,ks=proto(canonical,pi);patches=[]
for ii,(off,word) in enumerate(ins):
 if word[0]!=0x15:continue
 k=struct.unpack_from('<I',word,4)[0];tag,val=ks[k]
 if tag=='str' and pool[val-1].decode() in ['PILLAR_DURATION','PILLAR_DURATION_CIRCLE']:
  prev_off,prev=ins[ii-1];assert prev[0]==0x12 and struct.unpack_from('<h',prev,2)[0]==90
  patches.append({'prototype':pi,'instruction':ii-1,'offset':prev_off,'expected':list(b[prev_off:prev_off+4]),'register':prev[1],'value':'exolizer_speed_multiplier','numerator':90,'denominator':1,'inverse':True,'owner':pool[val-1].decode()})
assert len(patches)==2,patches
records['void_cascade']={'body_key':key(b),'file':name,'sha256':hashlib.sha256(b).hexdigest().upper(),'module_path':'Lotus.Scripts.Modes.ZarimanSurvivalMission','patches':patches}
for ident,rec in records.items():
 names=sorted({p['value'] for p in rec['patches']}) if rec['patches'] else (['reward_interval','pickup_life_support','pickup_reward_progress'] if ident=='survival' else ['scoring_speed_multiplier'])
 rec['parameters']={k:{'minimum':0 if k.startswith('pickup_') else 0.01 if 'multiplier' in k else 1,'maximum':100 if 'multiplier' in k else 32767} for k in names}
profile={'schema':1,'build':'2026.09.24.13.29','corpus':'shared/corpus/de-luau-u44-authoring','missions':records}
(editor/'REGISTRIES/mission_build_u44.json').write_text(json.dumps(profile,indent=2)+'\n');print('PROFILE',len(records),'patches',sum(len(x['patches']) for x in records.values()))

# Preserve the separately reviewed metadata and Descendia bindings on regeneration.
import runpy
runpy.run_path(str(editor/"RESEARCH/CARD_VALUE_LABELS_2026-09-27/scripts/register_controls.py"),run_name="__main__")
sys.argv=['bindings.py','--register']
runpy.run_path(str(editor/"RESEARCH/ARCHIMEDEA_TIMERS_2026-09-27/scripts/bindings.py"),run_name="__main__")
