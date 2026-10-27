extends SceneTree
var g
var checks: int=0
var cases: int=0
var failures: Array=[]
var visual: bool=false
func _initialize() -> void:call_deferred("run")
func check(ok: bool,message: String) -> void:
 checks+=1
 if not ok:failures.append(message);push_error("MENU RETURN: "+message)
func press(text: String) -> void:
 var action=g.MobileLayout.named(g.overlay,text)
 check(is_instance_valid(action),"Action exists: "+text)
 if action:action.pressed.emit()
func deplete() -> void:
 for i in range(g.current.lives):
  g.selected_answer="wrong "+str(i);g.submit()
func inspect_menu(tag: String) -> void:
 await process_frame;await process_frame;await process_frame
 var frame: Rect2=Rect2(420,80,530,360) if g.mobile_layout else Rect2()
 check(g.screen=="menu",tag+": returns to menu")
 check(g.art.presentation_rect==frame,tag+": uses the menu framing")
 check(g.art.camera==Vector2.ZERO,tag+": clears the previous camera offset")
 check(g.art.menu_mode and g.art.show_pair and g.art.room==0,tag+": menu composition includes both characters")
 check(g.art.visible and not g.art.frozen and not g.art.defeat_active and g.art.defeat_amount==0,tag+": visible scene without defeat effect")
 check(not g.paused and not g.banked_pause and g.pause_stage.is_empty(),tag+": no stale pause cycle")
 if visual:
  await RenderingServer.frame_post_draw
  check(g.art.origin.x>600,tag+": scenario is on the right")
func run() -> void:
 visual="--visual" in OS.get_cmdline_user_args()
 if visual:DirAccess.make_dir_recursive_absolute("user://captures");DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await create_timer(1.3 if visual else .1).timeout
 g.set_process(false);g.art.set_process(false);g.audio.stop_all();g.ui.modulate=Color.WHITE
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  if visual:DisplayServer.window_set_size(root.content_scale_size)
  for gender in ["female","male"]:
   for mode in ["normal","hard"]:
    for wing in range(3):
     for large in [false,true]:
      g.settings.large=large;g.settings.reduced=large
      for route in ["pause-world","pause-question","first-defeat","second-defeat"]:
       cases+=1
       var tag: String="%s/%s/ala%d/mobile=%s/large=%s/%s" % [gender,mode,wing+1,mobile,large,route]
       g.profiles=[];g.gender=gender;g.create_profile("Retorno",mode);g.cancel_gallery_transition()
       g.current.done=range(wing*4);g.current.introduced_galleries=[0,1,2];g.current.room=wing;g.room=wing;g.mission=wing*4
       g.world(true);await process_frame;await process_frame
       if route!="pause-world":g.start_question();await process_frame;await process_frame
       if route.begins_with("pause"):
        g.art.seated=true;g.pause_game();await process_frame;await process_frame
        check(g.banked_pause,tag+": reached the pause menu")
        press("Voltar ao menu");await process_frame;await process_frame
        press("Salvar e voltar")
       else:
        deplete();check(g.screen=="collapse",tag+": first defeat")
        if route=="first-defeat":g.leave_gameover()
        else:
         g.retry_gameover();await process_frame;await process_frame
         deplete();check(g.screen=="gameover_final",tag+": final defeat")
         g._process(4.7)
       await inspect_menu(tag)
       if visual and gender=="female" and mode=="normal" and wing==2 and not large and route=="second-defeat":
        g.title_label.elapsed=2;g.title_label.queue_redraw();await process_frame;await RenderingServer.frame_post_draw
        root.get_texture().get_image().save_png("user://captures/menu-return-"+("mobile" if mobile else "desktop")+".png")
 print("MENU RETURN: ",checks," checks; ",cases," combinations; failures=",failures.size())
 g.audio.stop_all();await create_timer(.2).timeout;quit(1 if not failures.is_empty() else 0)
