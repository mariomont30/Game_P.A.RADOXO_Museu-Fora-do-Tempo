extends SceneTree
var g
var checks: int=0
var problems: Array=[]
var captures: bool=false
func _initialize() -> void:call_deferred("run")
func check(ok: bool,note: String) -> void:
 checks+=1
 if not ok:problems.append(note);push_error("AUDIT FIX: "+note)
func key(code: int) -> void:
 var event:=InputEventKey.new();event.keycode=code;event.pressed=true;root.push_input(event)
 event=InputEventKey.new();event.keycode=code;event.pressed=false;root.push_input(event)
func shot(name: String) -> void:
 if not captures:return
 await process_frame;await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png("user://captures/"+name+".png")
func run() -> void:
 captures="--visual" in OS.get_cmdline_user_args()
 if captures:DirAccess.make_dir_recursive_absolute("user://captures")
 g=load("res://main.tscn").instantiate();root.add_child(g);g.testing=true
 await create_timer(1.3 if captures else .1).timeout;g.set_process(false);g.art.set_process(false);g.audio.stop_all()
 for mobile in [false,true]:
  g.mobile_layout=mobile;root.content_scale_size=Vector2i(960,540) if mobile else Vector2i(1280,800)
  if captures:DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);DisplayServer.window_set_size(root.content_scale_size)
  for large in [false,true]:
   g.settings.large=large
   for gender in ["female","male"]:
    for mode in ["normal","hard"]:
     for wing in range(3):
      g.menu();g.profiles=[];g.gender=gender;g.create_profile("Verificação",mode);g.current.done=range(wing*4);g.room=wing;g.world();await process_frame
      g.pause_game();await process_frame;await process_frame
      var footer: Label=null;var frame: Panel=null
      for c in g.overlay.get_children():
       if c is Label and c.text.contains("Progresso salvo"):footer=c
       if c is Panel:frame=c
      check(footer!=null and frame!=null,"Pause footer exists")
      if footer and frame:
       check(frame.get_global_rect().encloses(footer.get_global_rect()),"Pause footer stays inside its card")
       check(Rect2(Vector2.ZERO,Vector2(root.content_scale_size)).encloses(footer.get_global_rect()),"Pause footer stays on screen")
       check(footer.get_minimum_size().y<=footer.size.y,"Pause footer accommodates enlarged text")
      if mobile and large and gender=="female" and mode=="normal" and wing==1:await shot("mobile-large-pause")
      g.resume_from_bench();g._process(.5)
      check(not g.paused and g.pause_stage.is_empty() and not g.art.seated,"Pause behavior preserved")
   # Many valid names force a vertical scrollbar. Delete and mode/progress remain visible.
   g.menu();g.profiles=[]
   var names: Array=["💜".repeat(20),"W".repeat(20),"👩‍👩‍👧‍👦".repeat(20),"João ✨","Excluir"]
   for n in range(14):g.create_profile(names[n%names.size()],"hard" if n%2 else "normal")
   var originals: Array=g.profiles.map(func(profile):return profile.name)
   g.menu();g.profile_menu();await process_frame;await process_frame;await process_frame
   var sc: ScrollContainer=g.ui.get_children().filter(func(c):return c is ScrollContainer)[0]
   check(sc.get_h_scroll_bar().max_value-sc.get_h_scroll_bar().page<=1,"Journey list requires no horizontal scrolling")
   var list=sc.get_child(0).get_child(0)
   for i in range(list.get_child_count()):
    var row=list.get_child(i);var journey: Button=row.get_child(0);var remove: Button=row.get_child(1)
    check(journey.get_global_rect().position.x>=sc.get_global_rect().position.x-1,"Journey begins inside horizontal viewport")
    check(remove.get_global_rect().end.x<=sc.get_global_rect().end.x+1,"Delete remains inside horizontal viewport")
    check(journey.text.ends_with(" · %s · 0/12 obras" % ("Difícil" if i%2 else "Normal")),"Mode and progress survive name truncation")
    check(journey.tooltip_text.begins_with(originals[i]),"Full name remains available")
    check(g.profiles[i].name==originals[i],"Stored full name unchanged")
   if mobile and large:await shot("mobile-large-profiles")
   g.save_game();g.load_save()
   check(g.profiles.map(func(profile):return profile.name)==originals,"Save and reload preserve untruncated names")
   for reduced in [false,true]:
    g.menu();g.profiles=[];g.create_profile("Créditos","normal");g.current.done=range(12);g.settings.reduced=reduced;g.ending();g.credits();await process_frame;await process_frame
    g._process(2);g.toggle_credits_pause()
    var y: float=g.credit_roll.position.y
    if mobile:
     g.credit_button.grab_focus();key(KEY_LEFT)
     check(root.gui_get_focus_owner()==g.credit_resume_button,"Left arrow reaches Return to credits")
     key(KEY_RIGHT);check(root.gui_get_focus_owner()==g.credit_button,"Right arrow reaches Exit")
     key(KEY_UP);check(root.gui_get_focus_owner()==g.credit_resume_button,"Up arrow navigates credit buttons")
    key(KEY_PAGEDOWN);key(KEY_END);g._process(.2)
    check(g.credits_paused and g.credit_roll.position.y==y,"Paused letters remain fixed during navigation")
    check(not g.audio.paused,"Credits music is not paused with letters")
    if mobile:
     g.credit_resume_button.grab_focus()
     if large and not reduced:await shot("mobile-credit-keyboard")
     key(KEY_SPACE);check(not g.credits_paused,"Space activates Return to credits")
    else:
     key(KEY_ENTER);check(not g.credits_paused,"Enter still resumes desktop credits")
 print("AUDIT FIXES218: ",checks," checks; failures=",problems.size())
 g.menu();g.audio.stop_all();await create_timer(.3).timeout;quit(1 if not problems.is_empty() else 0)
