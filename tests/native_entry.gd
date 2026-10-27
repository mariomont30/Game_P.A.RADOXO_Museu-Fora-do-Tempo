extends SceneTree
var g
var failures: Array=[]
var checks: int=0
var visual: bool=false
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);push_error("NATIVE ENTRY: "+message)
func shot(name: String) -> void:
 if not visual:return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("user://captures/"+name+".png")
func run() -> void:
 visual="--visual" in OS.get_cmdline_user_args()
 if visual:DirAccess.make_dir_recursive_absolute("user://captures");DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);DisplayServer.window_set_size(Vector2i(1280,800))
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await create_timer(1.4 if visual else .1).timeout
 if not g.resources_ready:
  check(g.screen=="entry","Exported Windows starts at the welcome")
  await shot("windows-exported-auto-entry")
  g.start_native_loading()
  while not g.resources_ready:await process_frame
 g.set_process(false);g.audio.stop_all()
 g.profiles=[];g.create_profile("Jornada preservada","normal");g.start_question();await process_frame
 g.current.lives=2;g.current.defeats=1;g.time_left=35.5;g.update_snapshot();g.save_game()
 var id: String=g.current.id;var question: String=g.current.active.question.id;var options: Array=g.current.active.question.options.duplicate()
 for large in [false,true]:
  for reduced in [false,true]:
   g.settings.large=large;g.settings.reduced=reduced
   g.show_native_entry();g.ui.modulate=Color.WHITE
   check(g.screen=="entry" and not g.resources_ready,"Native welcome waits for the entry button")
   check(is_instance_valid(g.native_entry_scene) and g.native_entry_scene.show_pair,"Welcome includes the museum and two characters")
   check(g.title_label.reduced==reduced and g.native_entry_effects.reduced==reduced,"Motion preference respected")
   var original: String=FileAccess.get_file_as_string(g.SAVE)
   g.save_before_close();check(FileAccess.get_file_as_string(g.SAVE)==original,"Closing the welcome cannot erase existing journeys")
   if visual:await create_timer(1.4).timeout
   await shot("windows-entry"+("-large" if large else "")+("-reduced" if reduced else ""))
   g.start_native_loading()
   check(g.screen=="loading" and g.native_loading_progress.value==0,"Loading begins after entry")
   g.start_native_loading();check(g.screen=="loading","Repeated entry does not start another loader")
   g.save_before_close();check(FileAccess.get_file_as_string(g.SAVE)==original,"Closing before loading completes preserves the original save")
   await shot("windows-loading"+("-large" if large else "")+("-reduced" if reduced else ""))
   var frames: int=0
   while g.screen=="loading" and frames<240:await process_frame;frames+=1
   check(g.screen=="menu" and g.resources_ready,"Real preparation finishes at the main menu")
   check(g.db.size()==4200 and not g.question_by_id.is_empty(),"Question resources are prepared")
   check(g.get_child(0)==g.art,"Museum is behind the interface")
   var profile: Dictionary={}
   for p in g.profiles:
    if p.id==id:profile=p
   check(not profile.is_empty() and profile.lives==2 and profile.defeats==1,"Loading preserves the unfinished attempt")
   check(profile.active.question.id==question and profile.active.question.options==options and profile.active.remaining==35.5,"Loading preserves question, alternatives and time")
 print("NATIVE ENTRY219: ",checks," checks; failures=",failures.size())
 g.audio.stop_all();await create_timer(.2).timeout;quit(1 if not failures.is_empty() else 0)
