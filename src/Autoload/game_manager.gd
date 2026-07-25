extends Node

var time: float
var day: int

#dialogue_speed
var dialogue_speed := 0.03
const BEAVER_PORTRAIT = preload("uid://bnquvl81ws17j")
var is_player_movement_freeze: float = false

var dialogues = [
	{
		"image":BEAVER_PORTRAIT,
		"text":"Winter is coming... and time is running out."
	},
	{
		"image":BEAVER_PORTRAIT,
		"text":"Before the first snowfall"
	},
	{
		"image":BEAVER_PORTRAIT,
		"text":"I must prepare food , Reinforce the dam"
	},
	{
		"image":BEAVER_PORTRAIT,
		"text":"Protect my home."
	},
	{
		"image":BEAVER_PORTRAIT,
		"text":"Every day counts."
	}
]

enum Item {
	WOOD,
	STONE,
	FOOD,
	WATER
}

var player_inventory: Dictionary[Item, int] = {}


# func _process(delta):
# 	print(player_inventory)

func _ready() -> void:
	for item in Item.values():
		player_inventory[item] = 0


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

func basic_cutscene(camera: Camera2D, dialogue_ui: Control, texture_rect: TextureRect, text_label: Label , animation_player : AnimationPlayer , typewriter_audio : AudioStreamPlayer ,title,description):
	is_player_movement_freeze = true;
	dialogue_ui.visible = false;

	camera.zoom = Vector2.ONE

	var tween = create_tween()

	tween.parallel().tween_property(camera, "zoom", Vector2(1.5, 1.5), 2.0);
	await tween.finished
	animation_player.play("open_dialogue_box")
	await animation_player.animation_finished
	
	for d in dialogues:
		await show_dialogue(texture_rect, text_label, d.image, d.text,camera,typewriter_audio);

	animation_player.play("close_dialogue_box")
	tween = create_tween();
	tween.parallel().tween_property(camera, "zoom", Vector2(1.0, 1.0), 2.0)
	tween.parallel().tween_property(camera, "offset", Vector2(0, 0), 2.0)
	
	await tween.finished;
	black_screen(title,description,animation_player,typewriter_audio,"DAY 1","The countdown begins.")
	
# show_dialogue function

func show_dialogue(texture_rect: TextureRect, text_label: Label, image: Texture2D, message: String ,camera : Camera2D,typewriter_audio:AudioStreamPlayer):

	texture_rect.texture = image;
	text_label.text = "";
	
	typewriter_audio.play();
	
	for c in message:
		text_label.text += c
		await get_tree().create_timer(dialogue_speed).timeout

	# Wait for player input before next dialogue
	typewriter_audio.stop();
	await wait_for_continue(camera)


# wait_for_continue - wait for user to response;

func wait_for_continue(camera : Camera2D):

	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept"):
			camera.shake(8, 0.15)
			break

func black_screen(
	title: Label,
	description: Label,
	animation_player: AnimationPlayer,
	typewriter_audio : AudioStreamPlayer,
	screen_title: String,
	screen_des: String
):
	animation_player.play("open_black_screen")
	await animation_player.animation_finished

	title.text = ""
	description.text = ""
	
	typewriter_audio.play();
	for c in screen_title:
		title.text += c
		await get_tree().create_timer(dialogue_speed).timeout

	await get_tree().create_timer(0.3).timeout

	for c in screen_des:
		description.text += c
		await get_tree().create_timer(dialogue_speed).timeout

	typewriter_audio.stop();
	# Let the player read the text
	await get_tree().create_timer(3.5).timeout

	animation_player.play("close_black_screen")
	await animation_player.animation_finished
	is_player_movement_freeze = false;
