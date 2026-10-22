extends "res://scripts/museum.gd"
func _process(delta: float) -> void:
	if not reduced: time+=delta
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2(size.x/2,size.y*.84),0,Vector2.ONE*3.5)
	avatar(Vector2.ZERO)
	draw_set_transform(Vector2.ZERO)
