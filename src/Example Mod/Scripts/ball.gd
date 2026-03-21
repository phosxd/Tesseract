extends Area2D

var colors := PackedColorArray([
	Color.RED,
	Color.ORANGE_RED,
	Color.ORANGE,
	Color.YELLOW,
	Color.YELLOW_GREEN,
	Color.GREEN_YELLOW,
	Color.GREEN,
	Color.CYAN,
	Color.DEEP_SKY_BLUE,
	Color.BLUE,
	Color.PURPLE,
	Color.MAGENTA,
	Color.HOT_PINK,
])

var velocity := Vector2.ZERO
var color_iter:int = 0


func _process(delta:float) -> void:
	if Engine.get_process_frames() % 10 == 0:
		queue_redraw()
	position += velocity*delta
	position += Vector2(0, randf_range(-0.5, 0.5)) # Add deviation.


func _draw() -> void:
	# Get color.
	var color = colors.get(wrap(color_iter,0, colors.size()))
	color_iter += 1

	# Draw ball.
	var radius = $Shape.shape.radius
	draw_circle(Vector2.ZERO, radius, color)
