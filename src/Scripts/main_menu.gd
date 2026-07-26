extends Control

const MainGamePATH = "uid://cb60fs5k1qmjc";

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.main_menu();
	SceneManager.preload_scene(MainGamePATH);
	

func _on_play_button_pressed() -> void:
	if SceneManager.is_scene_loaded(MainGamePATH):
		SceneManager.change_scene(MainGamePATH);
		

func _on_exit_button_pressed() -> void:
	get_tree().quit();
