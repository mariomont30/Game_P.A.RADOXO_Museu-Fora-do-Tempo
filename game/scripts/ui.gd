extends Control
const GOLD := Color("e9c78b")
const INK := Color("132b39")
const MUTED := Color("b4c6ce")
const WHITE := Color("f5efe0")
const TEAL := Color("8adbc1")
var ui_feedback: Callable
var ui: Control
var overlay: Control
var settings: Dictionary={"master":.85,"music":.65,"effects":.7,"reduced":false,"large":false}
var paused: bool=false
var mobile_layout: bool=false
var mobile_layout_pending: bool=false
var mobile_applying: bool=false
const SCROLL_TEXT_GAP: int=24

func padded_scroll_content(scroll: ScrollContainer,content: Control) -> void:
	var margin:=MarginContainer.new()
	margin.add_theme_constant_override("margin_right",SCROLL_TEXT_GAP)
	margin.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	scroll.add_child(margin)
	margin.custom_minimum_size.x=maxf(0,scroll.size.x-maxf(16,scroll.get_v_scroll_bar().get_combined_minimum_size().x))
	if content.get_parent(): content.get_parent().remove_child(content)
	margin.add_child(content)
	content.custom_minimum_size.x=0
	content.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	content.size=Vector2(margin.custom_minimum_size.x-SCROLL_TEXT_GAP,0)

func init_ui() -> void:
	ui=Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.mouse_filter=Control.MOUSE_FILTER_IGNORE
	add_child(ui)

func clear_ui() -> void:
	ui.set_meta("mobile_laid_out",false)
	for child in ui.get_children():
		ui.remove_child(child); child.queue_free()

func style(color: Color,border: Color=Color("355264"),radius: int=14) -> StyleBoxFlat:
	var s:=StyleBoxFlat.new()
	s.bg_color=color; s.border_color=border
	s.set_border_width_all(1); s.set_corner_radius_all(radius)
	s.content_margin_left=16; s.content_margin_right=16
	s.content_margin_top=10; s.content_margin_bottom=10
	return s

func place(c: Control,r: Rect2,parent: Node=null) -> Control:
	(parent if parent!=null else ui).add_child(c)
	c.position=r.position; c.size=r.size
	c.set_meta("desktop_rect",r)
	if mobile_layout and not mobile_layout_pending and not mobile_applying:
		mobile_layout_pending=true
		call_deferred("_apply_mobile_layout")
	if c is ScrollContainer:
		c.focus_mode=Control.FOCUS_ALL
		c.follow_focus=true
		c.get_v_scroll_bar().focus_mode=Control.FOCUS_NONE
		c.get_h_scroll_bar().focus_mode=Control.FOCUS_NONE
		c.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.pressed: c.grab_focus())
		c.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
	if c is Slider or c is CheckButton or c is LineEdit:
		c.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
		c.mouse_entered.connect(func():
			if c is BaseButton and c.disabled: return
			if ui_feedback.is_valid(): ui_feedback.call())
		c.focus_entered.connect(func():
			if ui_feedback.is_valid(): ui_feedback.call())
	return c

func human_text(value: String) -> String:
	var out: String=value.replace(" — ",". ").replace(" – ",", ").replace("; ",". ").replace(";",".")
	return out

func label_at(text: String,r: Rect2,n: int=20,color: Color=WHITE,parent: Node=null) -> Label:
	var l:=Label.new()
	l.mouse_filter=Control.MOUSE_FILTER_IGNORE
	l.add_theme_color_override("font_color",color)
	l.add_theme_font_size_override("font_size",n+(2 if settings.large else 0))
	l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	if n<=27 and text.length()>75:
		l.horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
		l.justification_flags=TextServer.JUSTIFICATION_WORD_BOUND | TextServer.JUSTIFICATION_SKIP_LAST_LINE
	place(l,r,parent)
	l.text=human_text(text)
	return l

func button(text: String,r: Rect2,action: Callable,primary: bool=false,parent: Node=null) -> Button:
	var b:=Button.new()
	b.text=human_text(text)
	b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size",18+(1 if settings.large else 0))
	for key in ["font_color","font_focus_color"]: b.add_theme_color_override(key,INK if primary else WHITE)
	for key in ["font_hover_color","font_pressed_color"]: b.add_theme_color_override(key,INK)
	b.add_theme_stylebox_override("normal",style(GOLD if primary else Color("1d3849"),GOLD if primary else Color("426071")))
	b.add_theme_stylebox_override("hover",style(TEAL,TEAL))
	b.add_theme_stylebox_override("pressed",style(Color("76bfa9"),TEAL))
	var focus:=style(Color(0,0,0,0),TEAL); focus.set_border_width_all(3)
	b.add_theme_stylebox_override("focus",focus)
	b.pressed.connect(action)
	b.focus_entered.connect(func():
		if not b.disabled and ui_feedback.is_valid(): ui_feedback.call())
	place(b,r,parent)
	b.mouse_entered.connect(func():
		if b.disabled: return
		if ui_feedback.is_valid(): ui_feedback.call()
		if not settings.reduced:
			b.pivot_offset=b.size*.5
			if b.has_meta("hover_tween"): b.get_meta("hover_tween").kill()
			var tween:=b.create_tween(); b.set_meta("hover_tween",tween)
			tween.tween_property(b,"scale",Vector2.ONE*1.025,.12))
	b.mouse_exited.connect(func():
		if b.has_meta("hover_tween"): b.get_meta("hover_tween").kill()
		var tween:=b.create_tween(); b.set_meta("hover_tween",tween)
		tween.tween_property(b,"scale",Vector2.ONE,.12))
	return b

func panel(r: Rect2,parent: Node=null) -> Panel:
	var p:=Panel.new()
	p.add_theme_stylebox_override("panel",style(Color(.045,.10,.15,.98)))
	place(p,r,parent)
	return p

func field(r: Rect2,placeholder: String,parent: Node=null) -> LineEdit:
	var f:=LineEdit.new()
	f.placeholder_text=placeholder
	f.add_theme_font_size_override("font_size",23)
	f.add_theme_color_override("font_color",WHITE)
	f.add_theme_stylebox_override("normal",style(Color("1d3849")))
	f.add_theme_stylebox_override("focus",style(Color("1d3849"),Color("78909c")))
	place(f,r,parent)
	return f

func make_overlay(stop_time: bool=true) -> void:
	paused=stop_time
	if is_instance_valid(overlay): remove_child(overlay); overlay.queue_free()
	overlay=Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	var shade:=ColorRect.new()
	shade.color=Color(.025,.05,.08,.98)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(shade)

func close_overlay() -> void:
	if is_instance_valid(overlay): remove_child(overlay); overlay.queue_free(); overlay=null
	paused=false

func info(title: String,body: String,action: Callable=Callable(),caption: String="",stop_time: bool=true) -> void:
	make_overlay(stop_time)
	var font: Font=get_theme_font("font")
	var measure:=label_at(body,Rect2(-2000,-2000,756-SCROLL_TEXT_GAP,0),22,WHITE,overlay)
	var measured_height: float=measure.get_minimum_size().y
	var compact: bool=measured_height<=240
	var width: float=860 if compact else 1000
	var text_width: float=width-104
	measure.free()
	var body_height: float=clampf(measured_height+16,90,256) if compact else 470
	var title_height: float=maxf(65,font.get_multiline_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,width-80,31+(2 if settings.large else 0)).y+8)
	var height: float=40+title_height+24+body_height+28+52+28
	var x: float=(1280-width)*.5
	var y: float=(800-height)*.5
	var body_y: float=y+40+title_height+24
	var footer_y: float=body_y+body_height+28
	panel(Rect2(x,y,width,height),overlay)
	label_at(title,Rect2(x+40,y+32,width-80,title_height),31,GOLD,overlay)
	var scroll:=ScrollContainer.new()
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	place(scroll,Rect2(x+40,body_y,width-80,body_height),overlay)
	var text_label:=label_at(body,Rect2(0,0,text_width,0),22,WHITE,scroll)
	text_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
	text_label.justification_flags=TextServer.JUSTIFICATION_WORD_BOUND | TextServer.JUSTIFICATION_SKIP_LAST_LINE
	padded_scroll_content(scroll,text_label)
	var back:=button("Voltar",Rect2(x+40,footer_y,180,52),close_overlay,false,overlay)
	if action.is_valid(): button(caption,Rect2(x+width-40-365,footer_y,365,52),action,true,overlay)
	if compact: back.grab_focus()
	else: scroll.grab_focus()

func prose(text: String, rect: Rect2, font_size: int=22) -> void:
	var scroll:=ScrollContainer.new()
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	place(scroll,rect)
	var body:=label_at(text,Rect2(0,0,rect.size.x-24,0),font_size,WHITE,scroll)
	body.horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
	body.justification_flags=TextServer.JUSTIFICATION_WORD_BOUND | TextServer.JUSTIFICATION_SKIP_LAST_LINE
	padded_scroll_content(scroll,body)

func keyboard_controls(root: Node) -> Array[Control]:
	var result: Array[Control]=[]
	for node in root.get_children():
		if node is Control and not node.is_visible_in_tree(): continue
		if node is BaseButton:
			if not node.disabled and node.focus_mode!=Control.FOCUS_NONE: result.append(node)
		elif node is Slider or node is LineEdit or node is ScrollContainer:
			if node.focus_mode!=Control.FOCUS_NONE: result.append(node)
		result.append_array(keyboard_controls(node))
	return result

func keyboard_navigate(event: InputEventKey,root: Control) -> bool:
	var key: int=event.keycode
	if key not in [KEY_LEFT,KEY_RIGHT,KEY_UP,KEY_DOWN,KEY_TAB,KEY_PAGEUP,KEY_PAGEDOWN,KEY_HOME,KEY_END]: return false
	var controls: Array[Control]=keyboard_controls(root)
	if controls.is_empty(): return false
	var focus: Control=get_viewport().gui_get_focus_owner()
	if focus not in controls:
		controls[0].grab_focus(); return true
	if focus is LineEdit and key in [KEY_LEFT,KEY_RIGHT,KEY_HOME,KEY_END]: return false
	if focus is Slider and key in [KEY_LEFT,KEY_RIGHT,KEY_HOME,KEY_END]: return false
	if key==KEY_TAB:
		controls[posmod(controls.find(focus)+(-1 if event.shift_pressed else 1),controls.size())].grab_focus(); return true
	if focus is ScrollContainer and key in [KEY_UP,KEY_DOWN,KEY_PAGEUP,KEY_PAGEDOWN,KEY_HOME,KEY_END]:
		var bar: VScrollBar=focus.get_v_scroll_bar()
		var limit: float=maxf(0,bar.max_value-bar.page)
		if limit>0:
			var target: float=focus.scroll_vertical
			match key:
				KEY_UP: target-=48
				KEY_DOWN: target+=48
				KEY_PAGEUP: target-=focus.size.y*.85
				KEY_PAGEDOWN: target+=focus.size.y*.85
				KEY_HOME: target=0
				KEY_END: target=limit
			focus.scroll_vertical=roundi(clampf(target,0,limit))
			return true
	if key in [KEY_PAGEUP,KEY_PAGEDOWN,KEY_HOME,KEY_END]: return false
	var direction: Vector2=Vector2.LEFT if key==KEY_LEFT else Vector2.RIGHT if key==KEY_RIGHT else Vector2.UP if key==KEY_UP else Vector2.DOWN
	var center:=focus.get_global_rect().get_center()
	var best: Control=null
	var score: float=INF
	for candidate in controls:
		if candidate==focus: continue
		var offset:=candidate.get_global_rect().get_center()-center
		var advance: float=offset.dot(direction)
		if advance<=4: continue
		var lateral: float=absf(offset.cross(direction))
		var cost: float=advance+lateral*3
		if cost<score: score=cost; best=candidate
	if best==null: best=controls[posmod(controls.find(focus)+(-1 if key in [KEY_UP,KEY_LEFT] else 1),controls.size())]
	best.grab_focus()
	return true
