extends Object


## Runs bot logic.
func tick(target:Node2D, _speed:float, position:Vector2, _velocity:float) -> Dictionary[String,Variant]:
	# Hehehe, just copy the ball position.
	return {
		'position': Vector2(position.x, target.position.y)
	}
