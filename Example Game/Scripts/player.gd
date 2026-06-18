extends RigidBody2D

enum Controller {
	Bot,
	Player,
}

@export var controller := Controller.Bot
@export var bot_target: Node2D
@export var speed:float = 10.0
var anchor_x: float
var bot_logic: Object


func _ready() -> void:
	anchor_x = position.x
	bot_logic = load('res://Example Game/Scripts/bot_logic.gd') as GDScript
	if bot_logic: bot_logic = bot_logic.new()


func _process(_delta:float) -> void:
	position.x = anchor_x

	# Poll user inputs when using player controller.
	if controller == Controller.Player:
		if Input.is_action_pressed('ui_up'):
			linear_velocity -= Vector2(0,speed)
		if Input.is_action_pressed('ui_down'):
			linear_velocity += Vector2(0,speed)

	# Call bot when using bot controller.
	elif controller == Controller.Bot && bot_target && bot_logic:
		var result = bot_logic.tick(bot_target, speed, position, linear_velocity.y)
		for key:String in result:
			var value = result[key]
			if key == 'position':
				PhysicsServer2D.body_set_state(
					get_rid(),
					PhysicsServer2D.BODY_STATE_TRANSFORM,
					Transform2D.IDENTITY.translated(value)
				)
			else: set(key, result[key])
