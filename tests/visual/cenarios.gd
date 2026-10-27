extends SceneTree
var g
func _initialize() -> void:call_deferred("run")
func run() -> void:
 DirAccess.make_dir_recursive_absolute("user://captures")
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await create_timer(.5).timeout;g.set_process(false);g.art.set_process(false);g.audio.stop_all()
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);DisplayServer.window_set_size(root.content_scale_size)
  for room in range(3):
   g.gender="male";g.create_profile("Explorador","normal");g.current.done=range(room*4);g.room=room;g.world()
   await process_frame;await process_frame;g.art.queue_redraw();await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("user://captures/"+("mobile" if mobile else "desktop")+"-gallery-"+str(room)+".png")
 print("SCENERY217: 6 captured gallery layouts")
 g.audio.stop_all();await create_timer(.3).timeout;quit()
