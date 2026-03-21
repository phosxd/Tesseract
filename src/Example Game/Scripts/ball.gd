extends Area2D

var color := Color.WHITE
var trail_color := Color.WHITE
var velocity := Vector2.ZERO


func _process(delta:float) -> void:
	position += velocity*delta
	position += Vector2(0, randf_range(-0.5, 0.5)) # Add deviation.


func _draw() -> void:
	var radius = $Shape.shape.radius
	draw_circle(Vector2.ZERO, radius, color)
