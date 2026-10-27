extends SceneTree
var g
var checks: Array=[]
var context: Dictionary={}
var base: String=""
func _initialize() -> void:call_deferred("run")
func check(id: String,ok: bool,detail: Dictionary={}) -> void:
 checks.append({"id":id,"pass":ok,"context":context.duplicate(),"detail":detail})
 if not ok:push_error("REGRESSION "+id+" "+JSON.stringify(context)+" "+JSON.stringify(detail))
func button_named(node: Node,name: String) -> Button:
 for c in node.get_children():
  if c is Button and c.text.strip_edges()==name:return c
  var found:=button_named(c,name)
  if found:return found
 return null
func scrolls(node: Node) -> Array:
 var out: Array=[]
 for c in node.get_children():
  if c is ScrollContainer:out.append(c)
  out.append_array(scrolls(c))
 return out
func reset(mode: String="normal",gender: String="female",room: int=0) -> void:
 g.menu();g.profiles=[];g.gender=gender;g.create_profile("Fiscalização 💜",mode)
 g.current.done=range(room*4);g.current.introduced_galleries=[0,1,2]
 g.room=room;g.mission=room*4;g.world();g.art.set_process(false)
func choose_profile(id: String) -> void:
 for profile in g.profiles:
  if profile.id==id:g.current=profile;return
func settle_bench() -> int:
 var frames: int=0
 while (g.art.bench_pending or not g.art.path.is_empty()) and frames<900:
  g.art._process(1.0/60);frames+=1
 return frames
func key(code: int) -> void:
 var e:=InputEventKey.new();e.keycode=code;e.pressed=true;root.push_input(e)
 e=InputEventKey.new();e.keycode=code;e.pressed=false;root.push_input(e)
func run() -> void:
 base=ProjectSettings.globalize_path("user://")
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await process_frame;g.set_process(false);g.art.set_process(false);g.audio.stop_all()
 # Setup must reject incomplete profiles before changing the game.
 g.new_game();var count: int=g.profiles.size();g.start_new_journey()
 check("SETUP_EMPTY_REJECTED",g.screen=="setup" and g.profiles.size()==count)
 g.setup_name.text="   ";g.select_setup_character("female");g.select_setup_mode("normal")
 check("SETUP_WHITESPACE_REJECTED",not g.validate_setup())
 g.setup_name.text="João 💜";check("SETUP_UNICODE",g.validate_setup())
 check("NAME_GRAPHEME_LIMIT",g.clean_name("abcdefghijklmnopqrstu").length()==20)
 # Navigation, sitting, pausing, clock and overlays in all 24 core combinations.
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  for gender in ["female","male"]:
   for mode in ["normal","hard"]:
    for room in range(3):
     context={"mobile":mobile,"gender":gender,"mode":mode,"room":room}
     reset(mode,gender,room);await process_frame;await process_frame
     check("GALLERY_STARTS_SEATED",g.art.seated and g.current.seated and not g.paused)
     check("BENCH_STATUS_SEATED",g.bench_button.text=="Levantar" and g.status.text.contains("Levantar") if mobile else g.status.text.contains("sentado"))
     g.use_bench();g.sync_bench_status(true)
     check("BENCH_STATUS_STANDING",not g.art.seated and g.bench_button.text=="Sentar" and not g.status.text.contains("sentado"))
     for index in range(4):
      g.art.approach(index);g.art.pending=-1
      var frames: int=0;var collision: bool=false
      while not g.art.path.is_empty() and frames<900:
       g.art._process(1.0/60);frames+=1;collision=collision or g.art.blocked(g.art.hero)
      check("NAV_EXHIBIT_REACHABLE",frames<900 and g.art.near(index) and not collision,{"index":index,"frames":frames,"position":str(g.art.hero)})
      g.use_bench();frames=settle_bench()
      check("NAV_BENCH_REACHABLE",frames<900 and g.art.seated and not g.paused,{"index":index,"frames":frames})
     g.art.stand_up();g.art.hero=Vector2(.8,5.8);g.start_question();await process_frame
     g.time_left=33;var options: Array=g.question.options.duplicate();g.pause_game()
     check("PAUSE_WALKS_BEFORE_FREEZE",g.pause_stage=="walking" and not g.paused and not g.ui.visible)
     var elapsed: float=0
     while not g.banked_pause and elapsed<12:
      g.art._process(1.0/60);g._process(1.0/60);elapsed+=1.0/60
     check("PAUSE_AFTER_SITTING",g.banked_pause and g.paused and g.art.seated,{"seconds":elapsed})
     var remaining: float=g.time_left;g._process(.5)
     check("PAUSE_FREEZES_CLOCK",g.time_left==remaining)
     check("HARD_CLOCK_DURING_WALK",absf(remaining-(33-elapsed if mode=="hard" else 33))<.05,{"remaining":remaining,"walk_seconds":elapsed})
     g.returning_to_pause=true;g.open_settings();g.settings_back()
     check("SETTINGS_RETURNS_TO_PAUSE",g.banked_pause and g.overlay_kind=="pause")
     g.info("Como jogar",g.help_text());g.close_overlay()
     check("HELP_RETURNS_TO_PAUSE",g.banked_pause and g.overlay_kind=="pause")
     g.resume_from_bench();g._process(.5)
     check("RESUME_RISES",not g.paused and g.pause_stage.is_empty() and not g.art.seated and g.ui.visible)
     check("PAUSE_PRESERVES_OPTIONS",g.question.options==options)
     g.time_left=30;g.notebook();g._process(.5)
     check("NOTEBOOK_CLOCK_RULE",absf(g.time_left-(29.5 if mode=="hard" else 30))<.001,{"time":g.time_left,"paused":g.paused})
     check("NOTEBOOK_SCROLL_GAP",scrolls(g.overlay)[0].get_child(0).get_theme_constant("margin_right")==24)
     g.close_overlay();g.time_left=24.25;g.skip_question();await process_frame
     check("SKIP_PRESERVES_TIME",g.time_left==24.25 if mode=="hard" else true)
     # Actual timeout followed by menu/reload must not deduct a second life.
     if mode=="hard":
      g.time_left=.05;g._process(.1)
      check("TIMEOUT_COSTS_ONE_LIFE",g.screen=="timeout" and g.current.lives==1)
      var id: String=g.current.id;g.save_game();g.menu();g.load_save();choose_profile(id);g.resume_profile();await process_frame
      var before: Dictionary={"screen":g.screen,"lives":g.current.lives,"phase":g.current.phase,"remaining":g.time_left}
      g._process(.1)
      check("TIMEOUT_RELOAD_NO_EXTRA_LOSS",g.current.lives==1 and g.screen=="timeout",{"before":before,"after_screen":g.screen,"after_lives":g.current.lives,"defeats":g.current.defeats})
     # Restored view must show the correct, fully restored object.
     reset(mode,gender,room);g.current.done=range(room*4+4);g.world(true)
     for index in range(4):
      var id: int=room*4+index;g.view_restored(id)
      var displays: Array=g.overlay.get_children().filter(func(c):return c.get_script()==g.Exhibit)
      check("RESTORED_VIEW_CORRECT",displays.size()==1 and displays[0].progress==1 and displays[0].kind==g.art.TYPES[room][index],{"id":id})
      g.close_overlay()
 # Credits: letters pause while scenery/music continue; reduced motion uses keyboard scroll.
 context={}
 for mobile in [false,true]:
  for reduced in [false,true]:
   g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
   reset();g.settings.reduced=reduced;g.current.done=range(12);g.ending();g.credits();await process_frame;await process_frame
   context={"mobile":mobile,"reduced":reduced}
   var y: float=g.credit_roll.position.y;g._process(.5)
   check("CREDITS_SCROLL_RULE",g.credit_roll.position.y==y if reduced else g.credit_roll.position.y<y)
   g.toggle_credits_pause();y=g.credit_roll.position.y;var scenery_clock: float=g.credit_elapsed;g._process(.5)
   check("CREDITS_PAUSE_LETTERS_ONLY",g.credit_roll.position.y==y and not g.audio.paused and (reduced or g.credit_elapsed>scenery_clock))
   if mobile:
    g.credit_button.grab_focus();key(KEY_LEFT);await process_frame
    check("CREDITS_KEYBOARD_REACHES_RESUME",root.gui_get_focus_owner()==g.credit_resume_button,{"focus":str(root.gui_get_focus_owner()),"resume":str(g.credit_resume_button)})
   g.toggle_credits_pause()
   if reduced:
    g.credit_viewport.grab_focus();key(KEY_END);await process_frame
    check("CREDITS_REDUCED_KEYBOARD_SCROLL",g.credit_viewport.scroll_vertical>0)
   else:
    g._process(200);check("CREDITS_AUTO_MENU",g.screen=="menu")
 # Practice after partial progress must retain the selected practice mission after reload.
 context={"flow":"practice"};g.settings.reduced=false;reset();g.current.done=[0,1,2];g.world(true);g.view_restored(0)
 var practice:=button_named(g.overlay,"Praticar novamente");practice.pressed.emit();await process_frame
 var practice_id: String=g.question.id;var journey: String=g.current.id;g.time_left=21;g.save_game();g.menu();g.load_save();choose_profile(journey);g.resume_profile()
 check("PRACTICE_RESUMES_SELECTED_WORK",g.mission==0 and g.question.id==practice_id and g.current.done==[0,1,2])
 # Storage recovery of a deliberately deleted journey.
 context={"flow":"explicit deletion and corrupt primary"};reset();var deleted: String=g.current.id;g.save_game();g.delete_profile(deleted)
 var deleted_was_absent: bool=not g.profiles.any(func(p):return p.id==deleted)
 var f=FileAccess.open(g.SAVE,FileAccess.WRITE);f.store_string("damaged by audit fixture");f.close();g.load_save()
 check("DELETED_PROFILE_NOT_RESURRECTED",deleted_was_absent and not g.profiles.any(func(p):return p.id==deleted),{"profiles_after_recovery":g.profiles.size()})
 var failures: Array=checks.filter(func(x):return not x.pass)
 var report={"checks":checks.size(),"passed":checks.size()-failures.size(),"failed":failures.size(),"results":checks}
 var out=FileAccess.open("user://audit-functional.json",FileAccess.WRITE);out.store_string(JSON.stringify(report,"  "));out.close()
 print("AUDIT FUNCTIONAL: ",checks.size()," checks; failures=",failures.size(),"; evidence=",base)
 g.menu();g.audio.stop_all();await create_timer(.3).timeout;quit(1 if not failures.is_empty() else 0)
