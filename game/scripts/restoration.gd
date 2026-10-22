extends Control
## A close-up restoration bench: the physical result stays visible while solving.
var renderer: Control
var kind: String="painting"
var progress: float=0
var time: float=0
var accent := Color("dfbd82")
var frozen: bool=false

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	clip_contents=true

func _process(delta: float) -> void:
	if not frozen: time+=delta
	queue_redraw()

func _draw() -> void:
	var bg:=StyleBoxFlat.new()
	bg.bg_color=Color("172e3d")
	bg.set_corner_radius_all(20)
	draw_style_box(bg,Rect2(Vector2.ZERO,size))
	for i in range(9): draw_circle(size*.5,190-i*17,Color(.5,.7,.63,.016))
	for i in range(12):
		var p:=Vector2(25+i*41,size.y-45)
		draw_line(p,p+Vector2(90,-42),Color(.4,.7,.65,.08),1,true)
	# Illustrations use a separate live museum renderer so its draw calls run in its own draw callback.
	draw_arc(size*.5+Vector2(0,30),120,0,TAU,90,Color(.8,.7,.5,.15),1,true)
