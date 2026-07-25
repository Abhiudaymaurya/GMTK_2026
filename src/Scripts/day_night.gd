extends CanvasModulate

@export var gradient_texture: GradientTexture1D
@export var day_length_in_minutes: float = 5.0
@export var initial_hour: float = 12.0

var time: float = 0.0
var day: int = 0

func _ready() -> void:
	time = initial_hour / 24.0
	var value: float = (sin(time * 2.0 * PI - PI / 2.0) + 1.0) / 2.0
	self.color = gradient_texture.gradient.sample(value)

func _process(delta: float) -> void:
	if GameManager.is_player_movement_freeze:
		return
		
	time += delta / (day_length_in_minutes * 60.0)

	if time >= 1.0:
		time -= 1.0
		day += 1

		SignalBus.day_changed.emit(day)

	# Send time to GameManager in 0-24 hour scale
	GameManager.time = time * 24.0
	GameManager.day = day

	var value: float = (sin(time * 2.0 * PI - PI / 2.0) + 1.0) / 2.0
	self.color = gradient_texture.gradient.sample(value)