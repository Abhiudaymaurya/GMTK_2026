extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

#external music
const game_over_music = preload("uid://cqgc81jst6tei");
const win_music = preload("uid://dvb6fj5i3mdld");
const Main_Menu = preload("uid://becvdf55235tl")
const OXIDIZED_LEAF_GameStart = preload("uid://m1klqlqalxry")
const COFFETI_AUDIO = preload("uid://ce53sn74xomdx")

var day_music : Array =  [
	#night-track
	preload("uid://becvdf55235tl"),
	#day-track
	preload("uid://dg5xfnq07nqee"),
	#night-track
	preload("uid://2rou5pu08t65"),
	#day-track
	preload("uid://8uog8xf314r0"),
	#night-track
	preload("uid://cksn1q2ltlruk"),
	#day-track
	preload("uid://dtyyomoy5x8us"),
	
]


func play_day(day:int):
	if day < 1 or day > day_music.size():
		return

	var stream = day_music[day - 1]

	if music_player.stream == stream:
		return

	music_player.stream = stream
	music_player.play()

func game_start():
	music_player.stop()
	music_player.stream = OXIDIZED_LEAF_GameStart;
	music_player.play()
	
func play_game_over():
	music_player.stop()
	music_player.stream = game_over_music;
	music_player.play()

func play_win():
	music_player.stop()
	music_player.stream = win_music
	music_player.play()
	
	
func main_menu():
	music_player.stop()
	music_player.stream = Main_Menu
	music_player.play()

func play_confetti_audio():
	music_player.stop()
	music_player.stream = COFFETI_AUDIO
	music_player.play()
