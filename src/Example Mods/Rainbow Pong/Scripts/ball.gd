extends Area2D

# Color & trail color are only here to keep compatatibility, they are not used.
var color: Color
var trail_color: Color

const gradient_steps:int = 3

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
## Color used on previous frame, used to interpolate.
var last_color: Color
var color_iter:int = 0


func _ready() -> void:
	# Generate a smoother color set from the original set by recrusively interpolating colors.
	for _i:int in gradient_steps:
		var iter_colors:PackedColorArray = colors.duplicate()
		var i:int = 0
		for item:Color in iter_colors:
			var next_item: Color
			if i+1 == iter_colors.size(): next_item = iter_colors.get(0) # Use first item as next item if we are at the end of the array.
			else: next_item = iter_colors.get(i+1)
			# Insert gradiated color between the 2 original colors.
			var lerped_color:Color = item.lerp(next_item, 0.5)
			colors.insert(((i+1)*2)-1, lerped_color) # The "((i+1)*2)-1" bit makes sure we are inserting the color at the proper position. We can't use the same index from the original set, we need to take into account all the interpolated colors added.
			i += 1


func _process(delta:float) -> void:
	if Engine.get_process_frames() % 2 == 0: queue_redraw()
	position += velocity*delta
	position += Vector2(0, randf_range(-0.5, 0.5)) # Add deviation.


func _draw() -> void:
	var new_color:Color = colors.get(wrap(color_iter,0, colors.size()))
	color_iter += 1
	# Draw ball.
	var radius = $Shape.shape.radius
	draw_circle(Vector2.ZERO, radius, new_color)
