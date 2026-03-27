extends Node2D

var color: Color = Color.WHITE
var radius: float = 6.0

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color.darkened(0.3), 1.0)
