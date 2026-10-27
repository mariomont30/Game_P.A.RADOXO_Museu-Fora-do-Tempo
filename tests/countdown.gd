extends SceneTree
var g
var checks: int=0
var cases: int=0
var failures: Array=[]
var alerts: Array=[]
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);push_error("COUNTDOWN: "+message)
func run() -> void:
 AudioServer.set_bus_mute(0,true)
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await create_timer(.1).timeout
 g.set_process(false);g.art.set_process(false);g.audio.stop_all();g.audio.set_process(false)
 g.audio.countdown_alert.connect(func(second):alerts.append(second))
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  for gender in ["female","male"]:
   for mode in ["normal","hard"]:
    for wing in range(3):
     cases+=1;g.audio.enabled=false;g.profiles=[];g.gender=gender;g.menu()
     g.create_profile("Cronômetro",mode);g.cancel_gallery_transition()
     g.current.done=range(wing*4);g.current.introduced_galleries=[0,1,2];g.room=wing;g.mission=wing*4;g.world(true);g.start_question()
     await process_frame;await process_frame
     var tag: String="%s/%s/ala%d/mobile=%s" % [gender,mode,wing+1,mobile]
     if mode=="hard":check(g.time_left>=60 and g.time_left<=90,tag+": begins within 1 minute to 1 minute 30 seconds")
     g.audio.enabled=true;alerts.clear();g.settings.master=.5;g.settings.effects=.4
     g.time_left=11.1;g._process(1.2)
     if mode=="normal":
      check(alerts.is_empty() and g.time_left==11.1,tag+": Normal has no countdown or alert")
      continue
     check(alerts==[10],tag+": single ten-second warning")
     check(g.audio.countdown_player.playing,tag+": audio channel started")
     check(is_equal_approx(g.audio.countdown_player.volume_db,linear_to_db(.5*.4*.72)),tag+": master and effects volume respected immediately")
     g.art.seated=true;g.pause_game();var frozen: float=g.time_left
     check(not g.audio.countdown_player.playing,tag+": pause stops the warning")
     g._process(3.0);check(g.time_left==frozen and alerts==[10],tag+": paused time produces no alerts")
     g.resume_from_bench();g._process(.5)
     check(not g.paused and alerts==[10],tag+": resume does not repeat the ten-second warning")
     frozen=g.time_left;g.skip_question();await process_frame;await process_frame
     check(g.time_left<=frozen and alerts==[10],tag+": skipping keeps time and does not replay warnings")
     for frame in range(110):g._process(.1)
     check(alerts==[10,5,4,3,2,1],tag+": final seconds pulse once each")
     check(g.screen=="timeout" and g.time_left==0,tag+": timeout follows the final pulse")
     check(not g.audio.countdown_player.playing,tag+": timeout clears the countdown channel")
     check(g.current.lives==1,tag+": timeout removes only one hard-mode heart")
     g.audio.enabled=false;g.start_question();await process_frame;await process_frame
     var old: Dictionary=g.current.duplicate(true);old.active.remaining=120.0
     check(g.valid_profile(old),tag+": previous clock metadata remains accepted")
     var migrated: Dictionary=g.normalize_profile(old)
     check(migrated.active.remaining==g.question_time_limit(migrated.active.question),tag+": old remaining time is capped at the new content limit")
     check(migrated.active.question==old.active.question and migrated.lives==old.lives and migrated.defeats==old.defeats,tag+": migration preserves question, choice order and chances")
     old.active.remaining=23.25
     check(g.normalize_profile(old).active.remaining==23.25,tag+": shorter saved time never grows")
     alerts.clear();g.audio.enabled=true;g.time_left=11;g._process(7.2)
     check(alerts==[4],tag+": delayed frames do not play a burst of old warnings")
     g.menu();g._process(.2)
     check(not g.audio.countdown_player.playing and alerts==[4],tag+": leaving the question stops warnings")
 # Check the complete current bank without modifying its saved question metadata.
 var limits: Dictionary={}
 for question in g.db:
  if question.mode!="hard":continue
  var duration: float=g.question_time_limit(question)
  check(duration in [60.0,75.0,90.0],"All hard-mode contents use the requested duration range")
  limits[duration]=true
 check(limits.size()==3,"The bank covers 60, 75 and 90 second challenges")
 print("COUNTDOWN: ",checks," checks; ",cases," combinations; failures=",failures.size())
 g.audio.stop_all();await create_timer(.2).timeout;quit(1 if not failures.is_empty() else 0)
