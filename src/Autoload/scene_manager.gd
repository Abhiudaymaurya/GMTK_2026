extends Node

#preload scene - help to preload scene for smother transition!

func preload_scene(PATH : String) -> void:
	ResourceLoader.load_threaded_request(PATH,"",true);

#check that scene loaded or not

func is_scene_loaded(path: String) -> bool:
	return ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED

#help to change_scene (in future we can add transition or loader)

func change_scene(PATH : String):
	if ResourceLoader.load_threaded_get_status(PATH) == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(PATH)
		get_tree().change_scene_to_packed(scene);
	else:
		print("Still loading...");
		return;
