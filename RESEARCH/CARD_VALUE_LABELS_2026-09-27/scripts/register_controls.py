"""Reproduce the three reviewed bindings from local, exact game evidence."""
from pathlib import Path
import hashlib, json, shutil, struct, sys
editor = Path(__file__).resolve().parents[3]
root = editor.parents[2]
artifacts = Path(__file__).resolve().parents[1] / 'artifacts'
sys.path.insert(0, str(root / 'archive/legacy-decompilers/transpiler-lab'))
import _flat_loader as F
import parse_luab as P
path = editor / 'REGISTRIES/mission_build_u44.json'
profile = json.loads(path.read_text())
definitions = [
 ('netracells', 'EntratiVoidVaults', '/Lotus/Scripts/Modes/EntratiVoidVaults.lua', '0c498e078835f9fe', '036522b0202ab810737f23c765e45050cb02f87b10f9c293932b3be8da24f85f', 'power_per_kill', 1, 100),
 ('descendia_shrine', 'CoHShrineDefenseLite', '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHShrineDefenseLite.lua', '1ef96aede7fe612e', '4bea96c94d8a22a6578139c47919e05d4a191d97a6a88cf371ed150bb11ed946', 'offering_generation_time', 1, 32767),
 ('descendia_excavation', 'CoHExcavationLite', '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHExcavationLite.lua', '415a57536412719f', 'c641b897157618608088a5cfbd1d5688ace5c12822f8adaadf95089c6491d0e8', 'dig_duration', 1, 32767),
]
for ident, name, module, key, digest, parameter, minimum, maximum in definitions:
    raw = artifacts / (name + '.lua_B')
    b = raw.read_bytes()
    assert hashlib.sha256(b).hexdigest() == digest
    filename = module.strip('/').replace('/', '_') + '_B'
    shutil.copyfile(raw, root / profile['corpus'] / filename)
    rec = dict(body_key=key, file=filename, sha256=digest.upper(), module_path=module, patches=[], parameters={parameter:dict(minimum=minimum,maximum=maximum)})
    if ident == 'descendia_excavation':
        _, entries = F.load_flat(b)
        co, size, _ = F.header_at(b, entries[23][0])
        count, offset = P.vi(b, co+size)
        for k in range(count):
            start=offset
            _, constants, end=P.parse_consts(b'\1'+b[offset:],0)
            offset+=end-1
            if k==90:
                assert constants[0][0]==2 and struct.unpack('<d',constants[0][1])[0]==45
                rec['patches'].append(dict(kind='number_constant',prototype=23,constant=90,offset=start+1,expected=list(b[start+1:offset]),value=parameter,numerator=1,denominator=1,owner='migration, battery limit, remaining time, partial progress'))
        assert list(b[21000:21004])==[8,34,45,0]
        rec['patches'].append(dict(prototype=23,instruction=736,offset=21000,expected=[8,34,45,0],register=34,value=parameter,numerator=1,denominator=1,owner='completion threshold'))
    else:
        metadata = json.loads((artifacts/'current-mission-metadata.json').read_text())
        owner = '/Lotus/Types/Gameplay/EntratiLab/VoidVaults/EntratiVoidVaultsScriptTrigger' if ident=='netracells' else '/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHShrineDefenseTrigger'
        field = '_enemyPowerFill' if ident=='netracells' else '_offeringGenerationTime'
        value = 1 if ident=='netracells' else 30
        assert f'{field}={value}\n' in metadata[owner]['text']
        rec['metadata'] = dict(owner=owner,field='Scripts.0.Script.'+field,value=parameter,stock=value)
    profile['missions'][ident]=rec
path.write_text(json.dumps(profile,indent=2)+'\n')

# Explicit rank/control-flow review, not grouping by matching numbers or labels.
source=root/'work/rendered-source/ability-editor/dc33836ea5685c89.luau'
raw=source.read_bytes().removeprefix(b'\xef\xbb\xbf')
lines=raw.decode().splitlines()
controls=[]
for variable,label,unit,tag,rank_lines,values in [
 ('v18_7','Damage','damage','WEAPON_DAMAGE_AMOUNT',[[186,327,1644],[180,322,1655],[174,317,1666],[169,313,1671]],[15000,20000,25000,30000]),
 ('v18_6','Duration','seconds','AVATAR_ABILITY_DURATION',[[185,326,1643],[179,321,1654],[173,316,1665],[168,312,1670]],[2,2,3,3]),
]:
    for rank,(locations,value) in enumerate(zip(rank_lines,values),1):
        for line in locations: assert lines[line-1].strip()==f'{variable} = {value}'
        controls.append(dict(id=f'{variable}.rank{rank}',label=f'{label} · Ability rank {rank}',unit=unit,variable=variable,label_tag='/Lotus/Language/Labels/'+tag,original=value,minimum=0,maximum=100000000,
            assignments=[dict(line=line,role=role) for line,role in zip(locations,['shared_setup','card','gameplay'])],
            evidence='Exact rank branches in shared setup, GetAbilityUpgradeLevelInfo and ActivateAbility. Damage feeds DoHorseSpawn; duration feeds the horse lifetime countdown. Native Strength/Duration modifiers retained.'))
registry=dict(schema=1,modules={'dc33836ea5685c89':dict(source_sha256=hashlib.sha256(raw).hexdigest().upper(),scope='Catalog snapshot; exact source only. Not a U44 catalog migration.',controls=controls)})
(editor/'REGISTRIES/linked_card_stats.json').write_text(json.dumps(registry,indent=2)+'\n')
print('PASS: three mission bindings and eight reviewed rank controls registered')
