extends Control
## Original animated wordmark: clock dial, staggered entrance and travelling light.
var reduced: bool=false
var frozen: bool=false
var elapsed: float=0

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if not frozen and not reduced: elapsed+=delta
	queue_redraw()

func _draw() -> void:
	var font:=get_theme_default_font()
	var gold:=Color("e9c78b")
	var center:=Vector2(487,50)
	for radius in [47,58]: draw_arc(center,radius,0,TAU,80,Color(.91,.78,.54,.14),1.2,true)
	for i in range(12):
		var direction:=Vector2.from_angle(i*TAU/12)
		draw_line(center+direction*51,center+direction*56,Color(.54,.86,.76,.35),1.5,true)
	var angle: float=-PI/2 if reduced else elapsed*.35-PI/2
	draw_line(center,center+Vector2.from_angle(angle)*38,Color(.54,.86,.76,.35),2,true)
	draw_line(center,center+Vector2.from_angle(angle*.25)*23,Color(.91,.78,.54,.3),2,true)
	var x: float=0
	var word: String="P.A.RADOXO"
	for i in range(word.length()):
		var letter: String=word[i]
		var entry: float=1.0 if reduced else clampf((elapsed-i*.065)/.65,0,1)
		var y: float=77+(1-entry)*18+(0 if reduced else sin(elapsed*1.3+i*.22)*1.2)
		var light: float=0 if reduced else pow(maxf(0,cos(elapsed*1.8-i*.5)),14)*.7
		var color:=gold.lerp(Color("fff7d9"),light); color.a=entry
		draw_string(font,Vector2(x+2,y+4),letter,HORIZONTAL_ALIGNMENT_LEFT,-1,66,Color(.04,.14,.18,.8*entry))
		draw_string(font,Vector2(x,y),letter,HORIZONTAL_ALIGNMENT_LEFT,-1,66,color)
		x+=font.get_string_size(letter,HORIZONTAL_ALIGNMENT_LEFT,-1,66).x+1
	var length: float=410
	draw_line(Vector2(0,100),Vector2(length,100),Color(.91,.78,.54,.28),1,true)
	if not reduced:
		var spark:=Vector2(fmod(elapsed*65,length),100)
		draw_circle(spark,2.2,Color("fff1be"))
