extends "res://scripts/museum.gd"
var kind: String="painting"
var progress: float=0
var display_scale: float=2.5

func _process(delta: float) -> void:
	if not frozen and not reduced: time+=delta
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(size.x/2,size.y*.78),0,Vector2.ONE*display_scale)
	ellipse(Vector2(5,8),54,15,Color(0,0,0,.20))
	match kind:
		"painting": painting(Vector2.ZERO,progress,0)
		"portrait": portrait(Vector2.ZERO,progress)
		"time_core": time_core(Vector2.ZERO,progress)
		"statue": statue(Vector2.ZERO,progress)
		"mosaic": mosaic(Vector2.ZERO,progress)
		"dinosaur": dinosaur(Vector2.ZERO,progress)
		"crystal": crystal(Vector2.ZERO,progress)
		"fossil": fossil(Vector2.ZERO,progress)
		"vitrine": vitrine(Vector2.ZERO,progress)
		"clock": clock(Vector2(0,-35),35,GOLD,progress>=1)
		"orrery": orrery(Vector2.ZERO,progress)
		"machine": machine(Vector2.ZERO,progress)
	draw_set_transform(Vector2.ZERO)
