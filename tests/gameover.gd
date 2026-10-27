extends SceneTree
var g
var checks: int=0
var cases: int=0
func _initialize() -> void: call_deferred("run")
func check(value: bool,message: String) -> void:
 checks+=1
 if not value:
  push_error("FAIL: "+message)
  quit(1)
func select_profile(id: String) -> void:
 for profile in g.profiles:
  if profile.id==id: g.current=profile; return
 check(false,"Profile exists: "+id)
func wrong(value: String) -> void:
 g.selected_answer=value; g.submit()
func run() -> void:
 g=load("res://main.tscn").instantiate(); root.add_child(g); g.testing=true
 await process_frame; g.set_process(false); g.art.set_process(false)
 g.profiles=[]; g.settings.master=.37
 g.create_profile("Outra jornada","normal"); g.current.done=[0]
 var other: String=g.current.id
 for mobile in [false,true]:
  g.mobile_layout=mobile; root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  for gender in ["female","male"]:
   g.gender=gender
   for mode in ["normal","hard"]:
    for wing in range(3):
     for position in range(4):
      cases+=1
      g.settings.large=position%2==0; g.settings.reduced=position%2==1
      g.create_profile("Teste GAME OVER",mode)
      g.current.done=range(wing*4+position);g.room=wing;g.mission=wing*4+position
      g.start_question(); await process_frame
      var id: String=g.current.id;var original: String=g.question.id;var done: Array=g.current.done.duplicate()
      wrong("resposta inválida 1");check(g.current.lives==1,"First error costs one life")
      wrong("resposta inválida 1");check(g.current.lives==1,"Duplicate answer is free")
      wrong("resposta inválida 2")
      check(g.screen=="collapse" and g.current.defeats==1 and g.current.lives==0,"First game over")
      check(g.current.done==done,"First defeat preserves completed works")
      var old_time: float=g.time_left
      g._process(.4);check(g.time_left==old_time,"Game-over clock stopped")
      g.notebook();g._process(.4);check(g.time_left==old_time,"Book before retry is untimed");g.close_overlay()
      g.leave_gameover();g.load_save();select_profile(id);g.resume_profile()
      check(g.current.defeats==1 and g.screen=="collapse","Menu/reload do not reset defeat")
      g.retry_gameover()
      check(g.screen=="challenge" and g.current.lives==2 and g.current.defeats==1,"One retry resets only lives")
      check(g.question.id!=original and int(g.question.topic)==g.TOPICS[g.mission],"New question same content")
      check(g.time_left==float(g.question.time),"Retry restores time")
      old_time=g.time_left;g._process(.2);check(g.time_left==old_time,"Clock waits for question layout")
      await process_frame;g._process(.2)
      check(absf(g.time_left-(old_time-.2 if mode=="hard" else old_time))<.001,"Ready clock respects mode")
      g.update_snapshot();g.save_game();g.load_save();select_profile(id);g.resume_profile()
      check(g.current.defeats==1,"Retry survives another reload")
      var stale: Dictionary=g.current.duplicate(true)
      wrong("último erro 1");check(g.current.lives==1 and g.screen=="challenge","Retry allows one error")
      wrong("último erro 2")
      check(g.screen=="gameover_final" and g.current.is_empty(),"Second defeat retires profile immediately")
      check(id in g.ended_journeys,"Retirement is persisted separately")
      check(g.audio.final_defeat,"Distinct final audio state")
      g._process(4.7);check(g.screen=="menu","Second defeat returns to opening")
      check(g.profiles.size()==1 and g.profiles[0].id==other,"Other journey preserved")
      check(g.settings.master==.37,"Settings preserved")
      # Simulate a corrupt primary plus an older backup containing the lost journey.
      var f=FileAccess.open(g.SAVE+".bak",FileAccess.WRITE)
      f.store_string(JSON.stringify({"version":3,"profiles":[g.profiles[0],stale],"settings":g.settings}));f.close()
      f=FileAccess.open(g.SAVE,FileAccess.WRITE);f.store_string("corrupt");f.close()
      g.load_save()
      check(g.profiles.size()==1 and g.profiles[0].id==other,"Old backup cannot resurrect lost journey")
      g.save_game();g.save_game()
      await process_frame
 # Timeouts are defeats too, but only after both lives are spent.
 g.create_profile("Tempo","hard");g.start_question();await process_frame
 g.lose_charge(true);check(g.screen=="timeout" and g.current.lives==1,"First timeout is one life")
 g.start_question();g.lose_charge(true);check(g.screen=="collapse" and g.current.last_defeat_timeout,"Timeout first game over")
 g.retry_gameover();await process_frame;g.lose_charge(true);g.start_question();g.lose_charge(true)
 check(g.screen=="gameover_final","Timeout second defeat is terminal");g._process(4.7)
 # Pause keeps the actual frozen gallery visible and restores its frame.
 select_profile(other);g.resume_profile();g.world();g.art.seated=true
 var frame: Rect2=g.art.presentation_rect
 g.pause_game();check(g.banked_pause and g.art.frozen,"Bench before pause")
 check(g.overlay.get_child(0).color.a<.6,"Pause shade lets gallery show through")
 var scene_time: float=g.art.time;g.art._process(1);check(g.art.time==scene_time,"Paused scenery frozen")
 g.resume_from_bench();g._process(.5);check(not g.paused and g.art.presentation_rect==frame,"Resume restores scenery")
 # Learning panel: adaptive cards, real metrics, notebook return and no punctuation changes to math.
 for mobile in [false,true]:
  g.mobile_layout=mobile;g.current.learning={"2":{"sem_ajuda":3,"com_ajuda":1,"erros":2,"tempo_esgotado":1}}
  g.learning_summary();await process_frame
  check(g.overlay_kind=="learning" and is_instance_valid(g.learning_scroll),"Learning dashboard opens")
  g.open_learning_notebook();g.close_overlay();check(g.overlay_kind=="learning","Book returns to dashboard")
  g.close_overlay()
 check(g.human_text("r > 0: crescente; r < 0: decrescente.").contains("r < 0"),"Math variable case preserved")
 print("PASS GAMEOVER 2.15: ",checks," checks; ",cases," mission/layout/gender/mode/preferences combinations")
 g.audio.stop_all();await create_timer(.35).timeout;quit()
