extends Node

var development_mode = false;

var time: float
var day: int
var is_day_started: bool

var is_game_end: bool = false

# Store references so other functions can use them
var title: Label
var description: Label
var animation_player: AnimationPlayer
var typewriter_audio: AudioStreamPlayer

#dialogue_speed
var dialogue_speed := 0.03
var title_speed := 0.1
const BEAVER_PORTRAIT = preload("uid://bnquvl81ws17j")
var is_player_movement_freeze: bool = false

var dialogues = [
	{
		"image": BEAVER_PORTRAIT,
		"text": "Winter is coming... and time is running out."
	},
	{
		"image": BEAVER_PORTRAIT,
		"text": "Before the first snowfall"
	},
	{
		"image": BEAVER_PORTRAIT,
		"text": "I must prepare food , Reinforce the dam"
	},
	{
		"image": BEAVER_PORTRAIT,
		"text": "Protect my home."
	},
	{
		"image": BEAVER_PORTRAIT,
		"text": "Every day counts."
	}
]

var lodge_tier: int = 0
var stored_food: int = 0
var dam_health: int

enum Item {
	WOOD,
	STONE,
	FOOD
}

var player_inventory: Dictionary[Item, int] = {}


# func _process(delta):
# 	print(player_inventory)

func _ready() -> void:
	for item in Item.values():
		player_inventory[item] = 0

	SignalBus.day_changed.connect(_on_day_change)


func inv_add_item(item: Item, amount: int = 1) -> void:
	player_inventory[item] += amount


func inv_remove_item(item: Item, amount: int = 1) -> bool:
	if player_inventory[item] < amount:
		return false

	player_inventory[item] -= amount
	return true


func inv_has_item(item: Item, amount: int = 1) -> bool:
	return player_inventory[item] >= amount


# basic cutscene

func basic_cutscene(
		camera: Camera2D,
		dialogue_ui: Control,
		texture_rect: TextureRect,
		text_label: Label,
		animation_player_ref: AnimationPlayer,
		typewriter_audio_ref: AudioStreamPlayer,
		title_ref: Label,
		description_ref: Label
) -> void:
	if development_mode:
			animation_player_ref.play("close_dialogue_box")
			return ;

	animation_player = animation_player_ref
	typewriter_audio = typewriter_audio_ref
	title = title_ref
	description = description_ref


	is_player_movement_freeze = true;
	dialogue_ui.visible = false;

	camera.zoom = Vector2.ONE

	var tween = create_tween()

	tween.parallel().tween_property(camera, "zoom", Vector2(1.5, 1.5), 2.0);
	await tween.finished
	animation_player.play("open_dialogue_box")
	await animation_player.animation_finished

	for d in dialogues:
		await show_dialogue(texture_rect, text_label, d.image, d.text, camera, typewriter_audio);

	animation_player.play("close_dialogue_box")
	tween = create_tween();
	tween.parallel().tween_property(camera, "zoom", Vector2(1.0, 1.0), 2.0)
	tween.parallel().tween_property(camera, "offset", Vector2(0, 0), 2.0)

	await tween.finished;
	black_screen(title, description, animation_player, typewriter_audio, "7 DAYS LEFt", "The countdown begins.", is_game_end)

# show_dialogue function

func show_dialogue(texture_rect: TextureRect, text_label: Label, image: Texture2D, message: String, camera: Camera2D, typewriter_audio_ref: AudioStreamPlayer):
	texture_rect.texture = image;
	text_label.text = "";

	typewriter_audio_ref.play();

	for c in message:
		text_label.text += c
		await get_tree().create_timer(dialogue_speed).timeout

	# Wait for player input before next dialogue
	typewriter_audio_ref.stop();
	await wait_for_continue(camera)


# wait_for_continue - wait for user to response;

func wait_for_continue(camera: Camera2D):
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			camera.shake(8, 0.15)
			break

func black_screen(
	title_ref: Label,
	description_ref: Label,
	animation_player_ref: AnimationPlayer,
	typewriter_audio_ref: AudioStreamPlayer,
	screen_title: String,
	screen_des: String,
	keep_black: bool
):
	animation_player_ref.play("open_black_screen")
	await animation_player_ref.animation_finished

	title_ref.text = ""
	description_ref.text = ""

	typewriter_audio_ref.play();
	for c in screen_title:
		title_ref.text += c
		await get_tree().create_timer(title_speed).timeout

	await get_tree().create_timer(0.3).timeout

	for c in screen_des:
		description_ref.text += c
		await get_tree().create_timer(dialogue_speed).timeout

	typewriter_audio_ref.stop();
	# Let the player read the text
	await get_tree().create_timer(3.5).timeout
	
	if not keep_black:
		animation_player_ref.play("close_black_screen")
		await animation_player_ref.animation_finished
		is_player_movement_freeze = false;
		is_day_started = true
		SignalBus.day_started.emit()

func _on_day_change(new_day: int) -> void:
	is_player_movement_freeze = true
	is_day_started = false

	var days_left: int = 7 - new_day
	var days_text: String = "%d DAY%s LEFT" % [days_left, "" if days_left <= 1 else "S"]
	
	AudioManager.play_day(new_day);

	await black_screen(title, description, animation_player, typewriter_audio,
		days_text,
			"Another day has passed.", is_game_end
	)
	
	if new_day == 7:
		await game_over(game_evaluation())

func game_evaluation() -> String:
	if stored_food < 70:
		return "STARVED"
	elif dam_health < 50:
		return "FLOODED"
	elif lodge_tier < 1:
		return "FROZEN"
	else:
		return "SURVIVED"

func game_over(state: String) -> void:
	is_player_movement_freeze = true
	is_game_end = true

	match state:
		"STARVED":
			await black_screen(
				title, description, animation_player, typewriter_audio,
				"STARVED",
				"You did not gather enough food to survive the winter.",
				is_game_end
			)

		"FLOODED":
			await black_screen(
				title, description, animation_player, typewriter_audio,
				"FLOODED",
				"Your dam could not withstand the winter.",
				is_game_end
			)

		"FROZEN":
			await black_screen(
				title, description, animation_player, typewriter_audio,
				"FROZEN",
				"Your lodge was not prepared for the freezing winter.",
				is_game_end
			)

		"SURVIVED":
			await black_screen(
				title, description, animation_player, typewriter_audio,
				"SURVIVED",
				"You prepared well and survived the winter.",
				is_game_end
			)
			AudioManager.play_win();
			return ;
			
	AudioManager.play_game_over()
