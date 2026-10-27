extends SceneTree
var g
var checks: int=0
var failures: Array=[]
var visual: bool=false
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);push_error("LIVES: "+message)
func shot(name: String) -> void:
 if not visual:return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("user://captures/"+name+".png")
func run() -> void:
 visual="--visual" in OS.get_cmdline_user_args()
 if visual:DirAccess.make_dir_recursive_absolute("user://captures")
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await create_timer(1.4 if visual else .1).timeout
 g.set_process(false);g.art.set_process(false);g.audio.stop_all();g.ui.modulate=Color.WHITE
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  if visual:DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);DisplayServer.window_set_size(root.content_scale_size)
  for large in [false,true]:
   g.settings.large=large
   for gender in ["female","male"]:
    for mode in ["normal","hard"]:
     var limit: int=3 if mode=="normal" else 2
     for wing in range(3):
      g.menu();g.profiles=[];g.gender=gender;g.create_profile("Corações",mode)
      g.current.done=range(wing*4);g.room=wing;g.world()
      await process_frame;await process_frame
      var display=g.lives_label
      check(display.total==limit and display.filled==limit,"Mode starts at the correct heart limit")
      check(display.mode_text==("NORMAL" if mode=="normal" else "DIFÍCIL"),"Mode remains readable beside the hearts")
      check(Rect2(Vector2.ZERO,Vector2(root.content_scale_size)).encloses(display.get_global_rect()),"Hearts stay inside the viewport")
      check(display.position.x+display.size.x<=700 if mobile else display.position.x+display.size.x<=910,"Hearts do not overlap the progress counter")
      if visual and gender=="female" and wing==0:
       await shot(("mobile" if mobile else "desktop")+"-"+mode+("-large" if large else "")+"-full")
      g.start_question();await process_frame
      g.selected_answer="erro de teste";g.submit()
      check(g.lives_label.filled==limit-1 and g.current.lives==limit-1,"One wrong answer extinguishes one heart")
      g.submit();check(g.lives_label.filled==limit-1,"Repeated wrong answer does not extinguish another heart")
      g.skip_question();await process_frame
      check(g.lives_label.filled==limit-1,"Changing question does not recover or stack hearts")
      if visual and gender=="female" and wing==0:
       await shot(("mobile" if mobile else "desktop")+"-"+mode+("-large" if large else "")+"-lost-one")
   g.menu();g.new_game();await process_frame;await process_frame
   for child in g.ui.get_children():
    if child is Label and child.text.contains("corações"):
     check(child.get_minimum_size().y<=child.size.y+1,"Setup explanation fits normal and enlarged text")
   if visual:await shot(("mobile" if mobile else "desktop")+("-large" if large else "")+"-setup")
 print("LIVES219: ",checks," checks; failures=",failures.size())
 g.menu();g.audio.stop_all();await create_timer(.2).timeout;quit(1 if not failures.is_empty() else 0)
