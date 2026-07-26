extends Interactable

@export var amount: int = 1
@export var steps_to_break: int = 1
@export var cooldown: float = 0.5
@onready var sprite_2: Sprite2D = $Sprite2D2
@onready var sprite_1: Sprite2D = $Sprite2D

var can_progress_step: bool = true
var current_step: int = 0

func _ready() -> void:
	super._ready()
	sprite_2.visible = false
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

	super.interact()

func drop() -> void:
	super.drop()

func _process_break_step() -> void:
	_play_break_visual()

	if current_step >= steps_to_break:
		current_step = 0
		drop()

func _play_break_visual() -> void:
	_play_hit_shader()

	var original := sprite_1.scale
	var reduced := original * 0.9

	# sprite_2.scale = sprite_1.scale

	var tween := create_tween()

	tween.parallel().tween_property(sprite_1, "scale", reduced, 0.1)
	tween.parallel().tween_property(sprite_2, "scale", reduced, 0.1)

	tween.parallel().tween_property(sprite_1, "scale", original, 0.1)
	tween.parallel().tween_property(sprite_2, "scale", original, 0.1)
	
func _play_hit_shader() -> void:
	sprite_1.visible = false
	sprite_2.visible = true

	var mat := sprite_2.material.duplicate()
	sprite_2.material = mat
	mat.set("shader_parameter/get_hit", true)

	await get_tree().create_timer(0.3).timeout

	mat.set("shader_parameter/get_hit", false)
	sprite_2.visible = false
	sprite_1.visible = true
