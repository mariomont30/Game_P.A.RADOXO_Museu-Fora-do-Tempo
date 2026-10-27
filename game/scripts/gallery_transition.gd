extends Control
## Automatic gallery reveal without a skip action. Does not mutate gameplay or use its RNG.
signal finished
const Museum=preload("res://scripts/museum.gd")
const COLORS=[Color("e9c78b"),Color("e5b46e"),Color("83cfe5"),Color("a6e5ca")]
const TITLES=["Galeria de Arte","História Natural","Salão das Invenções","O museu voltou à vida"]
const QUOTES=["Toda grande descoberta começa com curiosidade. Vamos explorar?","O passado guarda novas pistas. Vamos encontrar a próxima descoberta?","Cada invenção nasceu de uma pergunta. É hora de fazer o tempo avançar.","As três engrenagens estão reunidas. Agora nossas histórias podem continuar."]
var destination: int=0
var kind: String="opening"
var reduced: bool=false
var large_text: bool=false
var mobile: bool=false
var character_gender: String="female"
var restored: Array=[]
var elapsed: float=0
var duration: float=3.8
var suspended: bool=false
var completed: bool=false
var scenery: Control
var shade: ColorRect
var effects: Control
var text_group: Control
var eyebrow: Label
var heading: Label
var chapter: Label
var quote: Label
var speaker: Label
var footer: Label
var scene_frame:=Rect2()
class Effects extends Control:
 var presentation: Control
 func _draw() -> void: presentation.paint_effects(self)
func _ready() -> void:
 mouse_filter=Control.MOUSE_FILTER_STOP
 clip_contents=true
 set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 duration=(.65 if not reduced else .5) if kind=="travel" else 3.8
 var background:=ColorRect.new();background.color=Color("101d2c");background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(background)
 scenery=Museum.new();scenery.room=mini(destination,2);scenery.gender=character_gender
 scenery.menu_mode=false;scenery.show_pair=false;scenery.preview=true;scenery.active=-1
 scenery.restored=restored.duplicate();scenery.seated=true;scenery.hero=scenery.BENCH_EXIT;scenery.reduced=reduced
 scenery.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(scenery)
 shade=ColorRect.new();shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);shade.mouse_filter=Control.MOUSE_FILTER_IGNORE;add_child(shade)
 effects=Effects.new();effects.presentation=self;effects.mouse_filter=Control.MOUSE_FILTER_IGNORE;effects.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(effects)
 text_group=Control.new();text_group.mouse_filter=Control.MOUSE_FILTER_IGNORE;text_group.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(text_group)
 var accent: Color=COLORS[destination]
 eyebrow=make_label("PRIMEIRA DESCOBERTA" if kind=="opening" else "ENGRENAGEM RECUPERADA" if kind=="advance" else "O RELÓGIO CENTRAL DESPERTOU" if kind=="finale" else "VIAGEM PELO MUSEU",16,accent)
 chapter=make_label("ALA %02d / 03" % (destination+1) if destination<3 else "12 OBRAS · 3 ENGRENAGENS",20,accent)
 heading=make_label(TITLES[destination],48,Color("f5efe0"))
 speaker=make_label("TICO",14,accent)
 quote=make_label(QUOTES[destination],21,Color("cdd8d8"))
 quote.horizontal_alignment=HORIZONTAL_ALIGNMENT_FILL
 quote.justification_flags=TextServer.JUSTIFICATION_WORD_BOUND | TextServer.JUSTIFICATION_SKIP_LAST_LINE
 footer=make_label("ENTRANDO NA GALERIA" if kind!="finale" else "UM NOVO AMANHÃ",13,Color("aabfc6"))
 if kind=="travel":
  for item in [eyebrow,speaker,quote,footer]:item.visible=false
 resized.connect(arrange);arrange();advance(0)
func make_label(value: String,font_size: int,color: Color) -> Label:
 var l:=Label.new();l.text=value;l.mouse_filter=Control.MOUSE_FILTER_IGNORE
 l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
 l.add_theme_font_size_override("font_size",font_size+(2 if large_text else 0))
 l.add_theme_color_override("font_color",color)
 l.add_theme_color_override("font_shadow_color",Color(0,0,0,.6));l.add_theme_constant_override("shadow_offset_y",2)
 text_group.add_child(l);return l
func arrange() -> void:
 var w: float=size.x;var h: float=size.y
 scene_frame=Rect2(w*.32,h*.05,w*.67,h*.77) if kind!="travel" else Rect2(w*.05,h*.02,w*.90,h*.94)
 var left: float=w*.06;var width: float=w*.47
 eyebrow.position=Vector2(left,h*.095);eyebrow.size=Vector2(w*.80,h*.06)
 chapter.position=Vector2(left,h*.30);chapter.size=Vector2(width,h*.065)
 heading.position=Vector2(left,h*.385);heading.size=Vector2(width,h*.22)
 var title_size: int=(38 if mobile else 50)+(2 if large_text else 0)
 while get_theme_default_font().get_multiline_string_size(heading.text,HORIZONTAL_ALIGNMENT_LEFT,width,title_size).y>h*.21 and title_size>28:title_size-=1
 heading.add_theme_font_size_override("font_size",title_size)
 speaker.position=Vector2(left,h*.66);speaker.size=Vector2(width,h*.045)
 quote.position=Vector2(left,h*.718);quote.size=Vector2(w*.68,h*.15)
 quote.add_theme_font_size_override("font_size",(18 if mobile else 22)+(2 if large_text else 0))
 footer.position=Vector2(left,h*.925);footer.size=Vector2(w*.80,h*.04)
 if kind=="travel":
  chapter.position=Vector2(left,h*.69);heading.position=Vector2(left,h*.76);heading.size.y=h*.19
  heading.add_theme_font_size_override("font_size",(30 if mobile else 40)+(2 if large_text else 0))
func _process(delta: float) -> void: advance(delta)
func advance(delta: float) -> void:
 if completed:return
 scenery.frozen=suspended
 if suspended:return
 elapsed=minf(duration,elapsed+maxf(0,delta))
 var reveal: float=smoothstep(0,.8 if kind!="travel" else .25,elapsed)
 var finish: float=1.0-smoothstep(duration-(.45 if kind!="travel" else .18),duration,elapsed)
 modulate.a=finish
 shade.color=Color(.025,.045,.075,lerpf(1,.22 if kind!="travel" else .18,reveal))
 text_group.modulate.a=smoothstep(.20,.82,elapsed) if kind!="travel" else reveal
 var shift: float=0 if reduced else (1.0-smoothstep(.25,1.25,elapsed))*18
 text_group.position.x=-shift
 var camera_scale: float=1.0 if reduced else lerpf(1.018,1.0,smoothstep(.35,3.2,elapsed))
 var center: Vector2=scene_frame.get_center()
 scenery.presentation_rect=Rect2(center-scene_frame.size*camera_scale*.5,scene_frame.size*camera_scale)
 effects.queue_redraw();scenery.queue_redraw()
 if elapsed>=duration:
  completed=true;set_process(false);finished.emit()
func paint_effects(canvas: Control) -> void:
 var w: float=size.x;var h: float=size.y;var accent: Color=COLORS[destination]
 # Dark reading area fades into the lit architecture, keeping each gallery visible.
 for i in range(42):
  var alpha: float=.74*pow(1.0-float(i)/42,1.4)
  canvas.draw_rect(Rect2(w*i/60.0,0,w/60.0+1,h),Color(.025,.045,.075,alpha))
 if kind=="travel":return
 var visibility: float=smoothstep(.22,1.0,elapsed)
 var center:=Vector2(w*.105,h*.225)
 var radius: float=23 if mobile else 31
 var angle: float=0 if reduced else elapsed*.27
 for i in range(12):
  var a: float=angle+TAU*i/12
  var offset:=Vector2(cos(a),sin(a))
  canvas.draw_line(center+offset*(radius-2),center+offset*(radius+6),Color(accent,visibility*.8),5,true)
 canvas.draw_arc(center,radius-5,0,TAU,64,Color(accent,visibility),3,true)
 canvas.draw_arc(center,radius*.42,0,TAU,40,Color(accent,visibility),2,true)
 canvas.draw_circle(center,3,Color("f5efe0"))
 canvas.draw_line(Vector2(w*.06,h*.89),Vector2(w*.94,h*.89),Color(accent,.18),1,true)
 canvas.draw_line(Vector2(w*.06,h*.89),Vector2(lerpf(w*.06,w*.94,elapsed/duration),h*.89),Color(accent,.70),2,true)
 if reduced:return
 for i in range(36):
  var seed_x: float=fposmod(sin(i*21.73+4)*613.31,1)
  var seed_y: float=fposmod(sin(i*17.29+8)*491.71,1)
  var p:=Vector2(w*(.12+seed_x*.83),h*fposmod(seed_y-elapsed*(.035+seed_x*.025),1))
  var opacity: float=visibility*(.10+.30*seed_x)*sin(PI*clampf(elapsed/3.8,0,1))
  canvas.draw_circle(p,1.2+seed_y*1.8,Color(accent,opacity))
 var halo:=Vector2(w*.78,h*.26)
 canvas.draw_arc(halo,h*.31+elapsed*3,.25,2.2,64,Color(accent,.045*visibility),12,true)
