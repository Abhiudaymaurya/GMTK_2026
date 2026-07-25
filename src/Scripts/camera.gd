extends Camera2D

var shake_strength := 0.0
var shake_timer := 0.0

func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta

		offset = offset.lerp(
			Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
			),
		0.5
	)
	else:
		offset = Vector2.ZERO


func shake(power: float, duration := 0.2):
	shake_strength = power
	shake_timer = duration
