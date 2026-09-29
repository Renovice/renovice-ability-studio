from pathlib import Path
import json,subprocess,copy,hashlib
root=Path(r"C:\Users\Bartek\OneDrive\Dokumenter\Warframe RE PROJECT RENOVICE");editor=root/"repos/apps/ability-editor";out=editor/"RESEARCH/U44_AUTHORING_2026-09-27/artifacts/profile-tests";out.mkdir(exist_ok=True)
profile=json.loads((editor/"REGISTRIES/mission_build_u44.json").read_text());cli=root/"work/builds/ability-editor/current/bin/renovice_ability_editor_cli.exe"
base=json.loads((editor/"EXAMPLES/mallet_linked_overguard_addon.json").read_text());results=[]
for ident,rec in profile["missions"].items():
 p=copy.deepcopy(base);p["id"]="mission."+ident+".u44-test";p["target"].update(module_body_key=rec["body_key"],module_path=rec["module_path"],installed_build=profile["build"])
 values={k:30 for k in rec["parameters"]}
 if ident in ("survival","interception"):
  p=json.loads((root/f"work/ability-projects/mission.{ident}.timers.addon/ability_edit.json").read_text());p["target"].update(module_body_key=rec["body_key"],module_path=rec["module_path"],installed_build=profile["build"])
  values={"reward_interval":150,"pickup_life_support":7,"pickup_reward_progress":5} if ident=="survival" else {"scoring_speed_multiplier":2}
 else:p["authoring_mode"]="MANAGED_MISSION_EXACT_REPLACEMENT"
 if ident=="mobile_defense":values={"minimum_total_time":60,"maximum_total_time":80}
 if ident=="void_cascade":values={"exolizer_speed_multiplier":2}
 if 'metadata' in rec:p['authoring_mode']='MANAGED_MISSION_METADATA_PATCH'
 if ident=='netracells':values={'power_per_kill':2}
 if ident=='descendia_shrine':values={'offering_generation_time':15}
 if ident=='descendia_excavation':values={'dig_duration':15}
 if ident=='archimedea':values={'eta_survival_minutes':5,'eta_defense_waves':3,'eda_survival_minutes':5,'eda_mirror_defenses':2,'eda_alchemy_mixtures':1,'eda_disruption_conduits':4}
 p["mission_profile"]={"build":profile["build"],"id":ident,"values":values}
 path=out/(ident+".json");path.write_text(json.dumps(p,indent=2));r=subprocess.run([str(cli),"build",str(path),"--staging",str(root/"work/staging/ability-editor-u44-tests"),"--editor-root",str(editor)],capture_output=True,text=True);(out/(ident+".log")).write_text(r.stdout+r.stderr);assert r.returncode==0,(ident,r.stdout,r.stderr);print("PASS",ident,flush=True)
 for name,mutate in [("wrong-body",lambda q:q["target"].update(module_body_key="0000000000000000")),("wrong-build",lambda q:q["mission_profile"].update(build="future")),("zero",lambda q:q["mission_profile"]["values"].update({next(iter(values)):-1}))]:
  q=copy.deepcopy(p);mutate(q);bad=out/(ident+"-"+name+".json");bad.write_text(json.dumps(q));r=subprocess.run([str(cli),"validate",str(bad),"--editor-root",str(editor)],capture_output=True,text=True);assert r.returncode!=0,(ident,name)
 results.append({"mission":ident,"build":"PASS","negativeCases":3})
(out/"results.json").write_text(json.dumps(results,indent=2));print(f"PASS {len(results)} builds and {len(results)*3} rejection cases")
