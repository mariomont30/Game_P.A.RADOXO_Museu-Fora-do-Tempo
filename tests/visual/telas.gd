extends SceneTree
var g
var problems: Array=[]
var shots: int=0
func _initialize() -> void: call_deferred("run")
func scan(node: Node,scrolling: bool=false) -> void:
 var in_scroll: bool=scrolling or node is ScrollContainer
 if node is Label and node.is_visible_in_tree() and not in_scroll:
  if node.get_minimum_size().y>node.size.y+1:
   problems.append(str(g.screen)+": clipped label "+node.text.left(90)+" needed="+str(node.get_minimum_size().y)+" height="+str(node.size.y))
 for child in node.get_children(): scan(child,in_scroll)
func shot(name: String) -> void:
 g.art.queue_redraw();await process_frame;await process_frame;await RenderingServer.frame_post_draw
 scan(g.overlay if is_instance_valid(g.overlay) else g.ui)
 root.get_texture().get_image().save_png("user://captures/"+name+".png")
 shots+=1
func run() -> void:
 DirAccess.make_dir_recursive_absolute("user://captures")
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
 await create_timer(1.3).timeout;g.set_process(false);g.art.set_process(false)
 for mobile in [false,true]:
  g.mobile_layout=mobile
  root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  DisplayServer.window_set_size(root.content_scale_size)
  var prefix: String="mobile" if mobile else "desktop"
  g.gender="female" if mobile else "male"
  for wing in range(3):
   g.settings.large=true;g.settings.reduced=false
   g.create_profile("Explorador de padrões","hard" if wing==2 else "normal")
   g.current.done=range(wing*4);g.room=wing;g.mission=wing*4;g.world();await process_frame
   g.art.seated=true;g.pause_game();await shot(prefix+"-pause-"+str(wing));g.resume_from_bench();g._process(.5)
   g.start_question();await process_frame
   g.selected_answer="errado1";g.submit();g.selected_answer="errado2";g.submit();g._process(1.05)
   await shot(prefix+"-gameover-"+str(wing))
   g.retry_gameover();await process_frame
   g.selected_answer="errado1";g.submit();g.selected_answer="errado2";g.submit();g._process(1.05)
   await shot(prefix+"-final-"+str(wing));g._process(4.7)
  g.create_profile("Aprendizado","normal");g.current.done=range(12)
  g.current.learning={"2":{"sem_ajuda":4,"com_ajuda":1,"erros":2},"6":{"com_ajuda":1,"erros":4,"puladas":2}}
  g.ending();g.learning_summary();await shot(prefix+"-learning")
  g.learning_scroll.scroll_vertical=440;await shot(prefix+"-learning-scroll")
  g.open_learning_notebook();await shot(prefix+"-learning-book");g.close_overlay();g.close_overlay()
  g.menu();await shot(prefix+"-menu");g.new_game();await shot(prefix+"-setup")
 print("VISUAL215: ",shots," screens; clipping findings=",problems.size())
 for problem in problems:print(problem)
 var f=FileAccess.open("user://captures/layout-findings.json",FileAccess.WRITE);f.store_string(JSON.stringify(problems));f.close()
 g.audio.stop_all();await create_timer(.35).timeout;quit()
