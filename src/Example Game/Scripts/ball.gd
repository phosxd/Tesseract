extends Area2D

const color := Color.WHITE
const trail_color := Color.WHITE

var velocity := Vector2.ZERO


func _process(delta:float) -> void:
	position += velocity*delta


func _draw() -> void:
	var radius = $Shape.shape.radius
	draw_circle(Vector2.ZERO, radius, color)
