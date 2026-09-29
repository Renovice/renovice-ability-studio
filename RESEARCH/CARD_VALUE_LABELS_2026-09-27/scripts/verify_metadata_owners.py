from pathlib import Path
import json,re,subprocess
root=Path(__file__).resolve().parents[6]
folder=Path(__file__).resolve().parents[1]
query=root/'work/research/U44-2026-09-27/endpoints/tools/metadata-query/bin/Debug/net9.0/query.exe'
packages=root/'work/research/U44-2026-09-27/Packages-new.dec'
output=folder/'artifacts/current-mission-metadata.json'
subprocess.run([str(query),str(packages),'EntratiVoidVaultsScriptTrigger$|CoHExcavationScriptTrigger$|CoHShrineDefenseTrigger$|Frost/Abilities/Ice(Shield|Spike)Ability$',str(output)],check=True)
def name_hash(s):
    n=0x768e5ed0
    for byte in s.encode(): n=((n^byte)*0x1000193)&0xffffffff
    n=(~n)&0xffffffff
    return ((n<<17)|(n>>15))&0xffffffff
bindings={'enemyPowerFill':0x9a8fa363,'questPowerMultiplier':0xf8ce5d4e,'offeringGenerationTime':0x0bf412f0}
for name,expected in bindings.items(): assert name_hash(name)==expected,(name,hex(name_hash(name)))
data=json.loads(output.read_text())
net=data['/Lotus/Types/Gameplay/EntratiLab/VoidVaults/EntratiVoidVaultsScriptTrigger']['text']
shrine=data['/Lotus/Types/Gameplay/DevilTower/LiteGameModes/CoHShrineDefenseTrigger']['text']
assert '_enemyPowerFill=1\n' in net and '_questPowerMultiplier=8\n' in net
assert '_offeringGenerationTime=30\n' in shrine
names=set()
for v in data.values(): names.update(re.findall(r'^(_\w+)=',v['text'],re.M))
for filename in ['EntratiVoidVaults','CoHShrineDefenseLite','CoHExcavationLite']:
    source=(folder/f'artifacts/{filename}.lua.readable.luau').read_text()
    for name in names:
        plain=name[1:]
        source=source.replace(f'Name__{name_hash(plain):08x}',plain)
    (folder/f'artifacts/{filename}.metadata-named.luau').write_text(source)
print('PASS current metadata values and all three exact U44 name-hash bindings; research aliases only')
