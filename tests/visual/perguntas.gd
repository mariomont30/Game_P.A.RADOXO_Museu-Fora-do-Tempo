extends SceneTree
var g
var issues: Array=[]
var count: int=0
func _initialize() -> void: call_deferred("run")
func scan(n: Node,scrolling: bool=false) -> void:
 var inside: bool=scrolling or n is ScrollContainer
 if n is Label and n.is_visible_in_tree() and not inside:
  if n.get_minimum_size().y>n.size.y+1: issues.append(str(g.question.id)+": "+n.text.left(50))
 for c in n.get_children():scan(c,inside)
func run() -> void:
 DirAccess.make_dir_recursive_absolute("user://captures")
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await create_timer(1).timeout;g.set_process(false);g.art.set_process(false);g.audio.stop_all()
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  DisplayServer.window_set_size(root.content_scale_size);g.settings.large=true
  for mode in ["normal","hard"]:
   g.gender="female" if mobile else "male";g.create_profile("Questões verificadas",mode)
   for topic in range(7):
    for family in ["sequencia","registros","tabela","mecanismo","restauracao"]:
     var pool: Array=g.db.filter(func(q):return q.mode==mode and int(q.topic)==topic and q.family==family)
     pool.sort_custom(func(a,b):return str(a.prompt).length()>str(b.prompt).length())
     g.mission=g.TOPICS.find(topic);g.start_question();g.question=pool[0].duplicate(true);g.challenge()
     await process_frame;await process_frame;await RenderingServer.frame_post_draw
     scan(g.ui);count+=1
     if family=="tabela" and topic in [0,3,6]:
      root.get_texture().get_image().save_png("user://captures/"+("mobile" if mobile else "desktop")+"-"+mode+"-"+str(topic)+".png")
 print("VISUAL216: ",count," long-format questions with large text; clipped labels=",issues.size())
 for issue in issues:print(issue)
 g.audio.stop_all();await create_timer(.3).timeout;quit(1 if not issues.is_empty() else 0)
