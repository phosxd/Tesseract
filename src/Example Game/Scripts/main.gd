extends Node2D

@export var background_color: ColorPalette
@export var start_ball_force:float = 300

var player_1_score:int = 0
var player_2_score:int = 0


func reset() -> void:
	%Score.text = '%s - %s' % [player_1_score, player_2_score]
	%Ball.velocity = Vector2.ZERO
	%Ball.position = Vector2(350, 200)
	get_tree().create_timer(0.75).timeout.connect(func() -> void:
		%Ball.velocity = Vector2((-1 if randf() > 0.5 else 1)*start_ball_force, 0)
	)


func _ready() -> void:
	if Engine.is_editor_hint(): return
	%Background.color = background_color.colors[0]
	reset()


func _process(_delta:float) -> void:
	pass


func _on_ball_body_entered(body:Node2D) -> void:
	var normal: Vector2
	var center: Vector2
	for body_2 in [%'Player 1', %'Player 2', %'Top Border', %'Bottom Border']:
		if body == body_2:
			center = body_2.position

	if body == %'Player 1': normal = Vector2(1,0)
	elif body == %'Player 2': normal = Vector2(-1,0)
	elif body == %'Top Border': normal = Vector2(0,1)
	elif body == %'Bottom Border': normal = Vector2(0,-1)

	%Ball.velocity = %Ball.velocity.bounce(normal)
	%Ball.velocity.x *= 1.025
	%Ball.velocity.y += %Ball.position.y-center.y


func _on_left_goal_area_entered(area:Area2D) -> void:
	if area != %Ball: return
	player_2_score += 1
	reset()


func _on_right_goal_area_entered(area:Area2D) -> void:
	if area != %Ball: return
	player_1_score += 1
	reset()
