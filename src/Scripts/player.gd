extends CharacterBody2D

const NORMAL_SPEED: float = 300.0 * 50.0
const WATER_SPEED: float = 300.0 * 35.0

var speed: float = NORMAL_SPEED

@onready var river_tile_map = $"../terrain_layers/river-water"
@onready var water_overlay: Sprite2D = $"water_overlay"

var last_dir: Vector2 = Vector2.DOWN
var current_context = null # Used by the context button to call current_context.interact()

func _ready() -> void:
	add_to_group("player")

	SignalBus.context_update.connect(_on_context_update)
	#signalbus.player_died.connect(_on_player_died)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("contextual") and current_context:
		if current_context.has_method("interact"):
			current_context.interact()
		else:
			push_warning("Current context does not have an interact() method.")


func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	handle_animation(direction)

	if direction != Vector2.ZERO:
		velocity = direction * speed * delta
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_context_update(interactable, entered: bool) -> void:
	if entered:
		current_context = interactable
	else:
		if current_context == interactable:
			current_context = null


func handle_animation(dir: Vector2) -> void:
	if is_player_in_water():
		speed = WATER_SPEED
		water_overlay.visible = true
	else:
		speed = NORMAL_SPEED
		water_overlay.visible = false

	if dir != Vector2.ZERO:
		last_dir = dir

		if abs(dir.x) > abs(dir.y):
			$AnimatedSprite2D.play("side_walk")
			$AnimatedSprite2D.flip_h = dir.x < 0
		elif dir.y < 0:
			$AnimatedSprite2D.play("back_walk")
		else:
			$AnimatedSprite2D.play("forward_walk")
	else:
		if abs(last_dir.x) > abs(last_dir.y):
			$AnimatedSprite2D.play("side_idle")
			$AnimatedSprite2D.flip_h = last_dir.x < 0
		elif last_dir.y < 0:
			$AnimatedSprite2D.play("back_idle")
		else:
			$AnimatedSprite2D.play("forward_idle")


func is_player_in_water() -> bool:
	var tile_pos = river_tile_map.local_to_map(river_tile_map.to_local(global_position))

	var tile_data = river_tile_map.get_cell_tile_data(tile_pos)

	return tile_data != null and tile_data.get_custom_data("is_water")