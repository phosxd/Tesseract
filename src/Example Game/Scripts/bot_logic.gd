extends Object


## Runs bot logic. Returns new velocity.
func tick(target:Node2D, speed:float, position:Vector2, velocity:float) -> Dictionary[String,Variant]:
	var target_diff:float = (target.position.y - position.y) # Get difference between bot position & target position.
	# If target is below bot & not severely overshooting, start moving down.
	if target_diff > 0 && velocity/4.0 < target_diff:
		velocity += speed
	# If target is above bot & not severely overshooting, start moving up.
	elif velocity/4.0 > target_diff:
		velocity -= speed

	var deviation: float
	if Engine.get_process_frames() % 50 == 0:
		deviation = [speed,-speed].pick_random()*5

	return {
		'linear_velocity': Vector2(0,velocity+deviation),
	}
