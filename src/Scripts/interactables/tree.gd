extends Interactable

@export var amount: int = 1
@export var steps_to_break: int = 1
@export var cooldown: float = 0.5

var can_progress_step: bool = true
var current_step: int = 0

func _ready() -> void:
	super._ready()

	drop_item = GameManager.Item.WOOD
	drop_amount = amount


func interact() -> void:
	if (not can_progress_step) or (not can_drop):
		return

	can_progress_step = false
	current_step += 1

	_process_break_step()

	await get_tree().create_timer(cooldown).timeout
	can_progress_step = true

func drop() -> void:
	super.drop()

func _process_break_step() -> void:
	_play_break_visual()

	if current_step >= steps_to_break:
		current_step = 0
		drop()

func _play_break_visual() -> void:
	var original_scale: Vector2 = $Sprite2D.scale
	var reduced_scale: Vector2 = original_scale * 0.9

	var tween := create_tween()
	tween.tween_property($Sprite2D, "scale", reduced_scale, 0.1)
	tween.tween_property($Sprite2D, "scale", original_scale, 0.1)
