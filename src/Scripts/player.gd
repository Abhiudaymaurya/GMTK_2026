extends CharacterBody2D

const NORMAL_SPEED: float = 300.0 * 50.0
const WATER_SPEED: float = 300.0 * 60.0

var speed: float = NORMAL_SPEED


@onready var river_tile_map = $"../terrain_layers/river-water"
@onready var water_overlay: Sprite2D = $"water_overlay"
@onready var camera_2d: Camera2D = $Camera2D

#INGame_UI - control node
@onready var control: Control = $InGame_UI/Control
#INGame_UI - text node
@onready var text: Label = $InGame_UI/Control/MarginContainer/VBoxContainer/dialogue_ui/MarginContainer/HBoxContainer/MarginContainer/text
#INGame_UI - texture_rect node
@onready var texture_rect: TextureRect = $InGame_UI/Control/MarginContainer/VBoxContainer/dialogue_ui/MarginContainer/HBoxContainer/MarginContainer2/TextureRect
#INGame_UI - animationplayer node - to play animation;
@onready var animation_player: AnimationPlayer = $InGame_UI/AnimationPlayer
#inGame_UI - Typewriter_audio
@onready var typewriter_audio: AudioStreamPlayer = $InGame_UI/typewriter_audio
#inGame_UI - black_screen_title
@onready var title: Label = $InGame_UI/balck_screen/MarginContainer/VBoxContainer/title
#inGame_UI - black_screen_description
@onready var description: Label = $InGame_UI/balck_screen/MarginContainer/VBoxContainer/description

@onready var hint_lable: RichTextLabel = $InGame_UI/hint/lable

# ui - inv
@onready var wood_count: Label = %wood_count
@onready var stone_count: Label = %stone_count
@onready var food_count: Label = %food_count

var prev_hint_text: String = ""

var last_dir: Vector2 = Vector2.DOWN
var current_context = null # Used by the context button to call current_context.interact()

func _ready() -> void:
	add_to_group("player")
	SignalBus.context_update.connect(_on_context_update);
	SignalBus.update_hint.connect(_set_hint)
	
	GameManager.basic_cutscene(
		camera_2d, control,
		texture_rect,
		text,
		animation_player,
		typewriter_audio,
		title,
		description
		); # cutscene function
		
	#signalbus.player_died.connect(_on_player_died)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("contextual") and current_context and !GameManager.is_player_movement_freeze:
		if current_context.has_method("interact"):
			current_context.interact()
		else:
			push_warning("Current context does not have an interact() method.")


func _physics_process(delta: float) -> void:
	if GameManager.is_player_movement_freeze:
		$"../ui".visible = false
		return
	else:
		if not $"../ui".visible:
			$"../ui".visible = true


	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()

	_handle_animation(direction)
	_update_ui()

	if direction != Vector2.ZERO:
		velocity = direction * speed * delta
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_context_update(interactable, hint_text: String, entered: bool) -> void:
	if entered:
		current_context = interactable
		
		hint_lable.visible = true
		_set_hint(hint_text)

	else:
		if current_context == interactable:
			current_context = null
			_set_hint("")
			hint_lable.visible = false


func _set_hint(hint: String) -> void:
	if prev_hint_text == hint:
		return

	hint_lable.visible_characters = 0
	hint_lable.text = hint
	prev_hint_text = hint

	for i in hint_lable.get_total_character_count():
		hint_lable.visible_characters = i + 1
		await get_tree().create_timer(GameManager.dialogue_speed).timeout

func _update_ui() -> void:
	wood_count.text = str(GameManager.player_inventory[GameManager.Item.WOOD])
	stone_count.text = str(GameManager.player_inventory[GameManager.Item.STONE])
	food_count.text = str(GameManager.player_inventory[GameManager.Item.FOOD])

func _handle_animation(dir: Vector2) -> void:
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
