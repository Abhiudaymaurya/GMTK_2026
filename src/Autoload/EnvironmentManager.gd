extends Node

@export var envirement_node_color_react_ref : ColorRect;

#shaders preload;
const SIMPLE_RAIN = preload("uid://cgvdb1ls77u7i")
const SIMPLE_SNOW = preload("uid://6fb38jkkslid")
const SUNNY = preload("uid://37q2mvux2lmy")
const COFFETI_ANIMATION_SHADER = preload("uid://bac6jk5g4qtpx")

var material : ShaderMaterial;

enum Weather {
	SUNNY,
	RAIN,
	SNOW
}

var current_weather : Weather = Weather.SUNNY


#coffeti-
var confetti_material: ShaderMaterial
var confetti_time := 0.0
var playing_confetti := false

func _ready() -> void:
	material = ShaderMaterial.new();

func _setup_(envirement_node : ColorRect):
	envirement_node_color_react_ref = envirement_node;
	change_envirement(0);
	
func _process(delta):

	if !playing_confetti:
		return

	confetti_time += delta

	var p = confetti_time / 1.2

	confetti_material.set_shader_parameter("progress", p)

	if p >= 1.0:
		playing_confetti = false
		envirement_node_color_react_ref.material = null
		_apply_shader();

func change_envirement(day : int):
	if day  <=  2:
		current_weather = Weather.RAIN;
		
	elif day == 3:
		current_weather = Weather.SNOW;
		
	elif day == 4:
		current_weather = Weather.SUNNY;
		
	elif day == 5:
		current_weather = Weather.SNOW;
		
	elif day == 7:
		current_weather = Weather.RAIN;
	
	_apply_shader();

func _apply_shader():
	match current_weather:
		Weather.SUNNY:
			material.shader = SUNNY
			envirement_node_color_react_ref.material = material;

		Weather.RAIN:
			material.shader = SIMPLE_RAIN
			envirement_node_color_react_ref.material = material

		Weather.SNOW:
			material.shader = SIMPLE_SNOW
			envirement_node_color_react_ref.material = material

func play_confetti():
	confetti_material = ShaderMaterial.new()
	confetti_material.shader = COFFETI_ANIMATION_SHADER

	envirement_node_color_react_ref.material = confetti_material
	AudioManager.play_confetti_audio()
	confetti_time = 0.0
	playing_confetti = true
