extends SceneTree
var g
var checks: int=0
var cases: int=0
var problems: Array=[]
var visual: bool=false
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:problems.append(message);push_error("TRANSITION: "+message)
func all_buttons(node: Node) -> Array:
 var found: Array=[]
 for c in node.get_children():
  if c is Button:found.append(c)
  found.append_array(all_buttons(c))
 return found
func scan_labels(node: Node) -> void:
 for c in node.get_children():
  if c is Label and c.visible:check(c.get_minimum_size().y<=c.size.y+1,"Cinematic label fits: "+c.text)
  scan_labels(c)
func setup(destination: int,mode: String,gender: String) -> void:
 g.menu();g.gender=gender;g.create_profile("Explorador de padrões",mode)
 g.current.done=range(mini(destination,3)*4);g.current.introduced_galleries=[]
 g.current.defeats=1;g.current.lives=1
 g.current.room=maxi(0,mini(2,destination-1));g.room=g.current.room;g.mission=mini(destination*4,11)
 g.time_left=37.5
func run() -> void:
 visual="--visual" in OS.get_cmdline_user_args()
 if visual:DirAccess.make_dir_recursive_absolute("user://captures")
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await process_frame;g.set_process(false);g.art.set_process(false);g.audio.stop_all()
 # Both modes, characters, layouts, text sizes and motion preferences.
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  if visual:DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);DisplayServer.window_set_size(root.content_scale_size)
  for gender in ["female","male"]:
   for mode in ["normal","hard"]:
    for large in [false,true]:
     for reduced in [false,true]:
      g.settings.large=large;g.settings.reduced=reduced
      for destination in range(4):
       cases+=1;setup(destination,mode,gender)
       var kind: String="opening" if destination==0 else "advance" if destination<3 else "finale"
       g.begin_gallery_transition(destination,kind)
       check(g.screen=="transition" and is_instance_valid(g.gallery_transition),"Cinematic starts")
       var transition=g.gallery_transition;transition.set_process(false)
       check(transition.destination==destination and transition.scenery.gender==gender,"Correct destination and character")
       check(all_buttons(transition).is_empty(),"Presentation has no skip button")
       check(not g.ui.visible and not g.art.visible,"Gameplay is covered")
       var old: Dictionary=g.current.duplicate(true)
       g._process(.5);transition.advance(1.7)
       check(g.current.lives==old.lives and g.current.defeats==old.defeats and g.current.seen==old.seen,"Lives, retry and draw history preserved")
       check(g.time_left==37.5 and g.touch_movement==Vector2.ZERO,"No timer or movement during presentation")
       var t: float=transition.elapsed;transition.suspended=true;transition.advance(.8)
       check(transition.elapsed==t,"Suspended presentation clock stops")
       transition.suspended=false
       await process_frame;await process_frame
       scan_labels(transition)
       if visual and gender=="female" and mode=="normal" and large and not reduced:
        transition.scenery._process(.02);transition.scenery.queue_redraw();transition.effects.queue_redraw()
        await process_frame;await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png("user://captures/"+("mobile" if mobile else "desktop")+"-arrival-"+str(destination)+".png")
       transition.advance(5)
       check(not is_instance_valid(g.gallery_transition),"Presentation completes automatically")
       check(g.screen==("ending" if destination==3 else "world"),"Correct scene after automatic finish")
       if destination<3:
        check(g.art.seated and g.room==destination and g.current.seated,"Player starts seated in destination")
        check(destination in g.current.introduced_galleries,"First entry recorded only after completion")
       else:check(g.current.done.size()==12,"Final reveal preserves every restored work")
       check(not g.audio.transitioning and g.ui.visible and g.art.visible,"Controls and music restored after finish")
 # Exercise real entry points, not only the transition class.
 g.mobile_layout=false;root.content_scale_size=Vector2i(1280,800);g.settings.reduced=false
 g.gender="male";g.create_profile("Primeira entrada","hard",true)
 check(g.screen=="transition" and g.gallery_transition.kind=="opening","Start journey presents Ala 01")
 g.gallery_transition.set_process(false);g.gallery_transition.advance(4)
 g.current.done=range(4);g.room=0;g.mission=3;g.continue_after_restore()
 check(g.gallery_transition.destination==1 and g.gallery_transition.kind=="advance","Fourth restoration presents Ala 02")
 g.gallery_transition.set_process(false);g.gallery_transition.advance(4)
 g.enter_gallery(0)
 check(g.gallery_transition.kind=="travel" and g.gallery_transition.duration<1,"Map revisits are brief")
 g.gallery_transition.set_process(false);g.gallery_transition.advance(1)
 g.enter_gallery(2);check(not is_instance_valid(g.gallery_transition),"Locked galleries cannot be entered")
 g.current.done=range(8);g.room=1;g.mission=7;g.continue_after_restore()
 check(g.gallery_transition.destination==2 and g.gallery_transition.kind=="advance","Eighth restoration presents Ala 03")
 g.gallery_transition.set_process(false);g.gallery_transition.advance(4)
 g.current.done=range(12);g.room=2;g.mission=11;g.continue_after_restore()
 check(g.gallery_transition.kind=="finale","Twelfth restoration presents finale")
 g.gallery_transition.set_process(false);g.gallery_transition.advance(4)
 # Closing before presentation ends cannot lose progress or grant a retry.
 g.create_profile("Entrada interrompida","hard",true);g.current.defeats=1;g.time_left=29
 var id: String=g.current.id;g.save_game();g.menu();g.load_save()
 for profile in g.profiles:
  if profile.id==id:g.current=profile
 g.resume_profile()
 check(g.screen=="transition" and g.current.defeats==1,"Interrupted first entry resumes safely")
 g.gallery_transition.set_process(false)
 # Keyboard and clicks cannot skip or move the player.
 var elapsed: float=g.gallery_transition.elapsed
 for key in [KEY_SPACE,KEY_ENTER,KEY_ESCAPE,KEY_RIGHT]:
  var e:=InputEventKey.new();e.keycode=key;e.pressed=true;root.push_input(e)
  e=InputEventKey.new();e.keycode=key;e.pressed=false;root.push_input(e)
 var click:=InputEventMouseButton.new();click.position=Vector2(650,400);click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;root.push_input(click)
 await process_frame
 check(g.screen=="transition" and g.gallery_transition.elapsed==elapsed,"Keys and clicks cannot skip presentation")
 g.gallery_transition.advance(4);g.save_game();g.menu();g.load_save()
 for profile in g.profiles:
  if profile.id==id:g.current=profile
 g.resume_profile();check(g.screen=="world","Completed introduction is not replayed on Continue")
 var legacy: Dictionary=g.current.duplicate(true);legacy.erase("introduced_galleries")
 check(g.valid_profile(legacy) and g.normalize_profile(legacy).introduced_galleries==[0,1,2],"Old save remains compatible without replay")
 var bad: Dictionary=g.current.duplicate(true);bad.introduced_galleries=[0,0]
 check(not g.valid_profile(bad),"Malformed gallery history rejected")
 for cue in ["arrival_art","arrival_nature","arrival_inventions","arrival_finale","gallery_travel"]:
  var stream=load("res://audio/"+cue+".wav")
  check(stream!=null and stream.get_length()>.4 and stream.get_length()<=3.81,"Sound exists and has bounded duration: "+cue)
 # Focus and rotation suspend the automatic reveal and its audio together.
 g.create_profile("Foco da apresentação","normal",true);g.gallery_transition.set_process(false)
 g.transition_focus_paused=true;g._process(.1)
 var held: float=g.gallery_transition.elapsed;g.gallery_transition.advance(.5)
 check(g.gallery_transition.elapsed==held and g.audio.paused,"Focus loss holds scene and sound")
 g.transition_focus_paused=false;g._process(.1);g.gallery_transition.advance(.5)
 check(g.gallery_transition.elapsed>held and not g.audio.paused,"Focus return resumes scene and sound")
 g.transition_orientation_paused=true;g._process(.1);held=g.gallery_transition.elapsed;g.gallery_transition.advance(.5)
 check(g.gallery_transition.elapsed==held,"Portrait orientation holds the reveal")
 g.transition_orientation_paused=false;g._process(.1);g.gallery_transition.advance(5)
 # New cues use a dedicated player so feedback cannot truncate them.
 g.audio.enabled=true;g.audio.effects_volume=.2
 g.audio.begin_arrival(1,"advance")
 check(g.audio.arrival.stream.resource_path.ends_with("arrival_nature.wav") and g.audio.arrival.playing,"Dedicated nature arrival plays")
 g.audio.hover();check(g.audio.arrival.playing,"Hover feedback does not replace arrival cue")
 g.audio.paused=true;check(g.audio.arrival.stream_paused,"Paused arrival stops with the presentation")
 g.audio.paused=false;check(not g.audio.arrival.stream_paused,"Arrival resumes after focus returns")
 g.audio.end_arrival();check(not g.audio.arrival.playing and not g.audio.transitioning,"Arrival ends cleanly")
 g.audio.stop_all()
 print("TRANSITIONS217: ",checks," checks; ",cases," combinations; failures=",problems.size())
 g.menu();g.audio.stop_all();await create_timer(.3).timeout;quit(1 if not problems.is_empty() else 0)
