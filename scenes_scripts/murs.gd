extends Control

var murs: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)

func _draw() -> void:
	if murs == Rect2(Vector2.ZERO, Vector2.ZERO):
		return
	draw_rect(murs, Color.BLACK, false, 4)
