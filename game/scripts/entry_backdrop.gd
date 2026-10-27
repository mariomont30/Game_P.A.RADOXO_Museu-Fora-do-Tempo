extends Control
var reduced: bool=false
var elapsed: float=0.0
func _ready() -> void:mouse_filter=Control.MOUSE_FILTER_IGNORE
func _process(delta: float) -> void:
 if reduced:return
 elapsed+=delta;queue_redraw()
func _draw() -> void:
 for i in range(22):
  draw_circle(Vector2(958,395),430-i*15,Color(.12,.36,.38,.012))
 for i in range(12):
  draw_circle(Vector2(1105,190),245-i*15,Color(.9,.58,.25,.008))
 var drift: float=0.0 if reduced else sin(elapsed*.22)*18
 draw_colored_polygon(PackedVector2Array([Vector2(925+drift,-20),Vector2(1080+drift,-20),Vector2(1220,700),Vector2(700,700)]),Color(.85,.73,.46,.018))
 for i in range(42):
  var x: float=fmod(i*137.3+sin(elapsed*.35+i)*9,1280)
  var y: float=fmod(i*71.7+elapsed*(3+i%3),800)
  draw_circle(Vector2(x,y),.8+(i%3)*.45,Color(.78,.87,.79,.12+(i%4)*.025))
