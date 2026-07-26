extends StaticBody2D
class_name Interactable

@export var drop_item: GameManager.Item = GameManager.Item.WOOD
@export var drop_amount: int = 1

var can_drop: bool = true


func _ready() -> void:
	if drop_amount <= 0:
		push_error("invalid parms set in editor.")

	SignalBus.day_changed.connect(_on_day_changed)


func _on_day_changed(_day: int) -> void:
	can_drop = true

func get_hint() -> String:
	if not can_drop:
		return ""

	match drop_item:
		GameManager.Item.WOOD:
			return "Press [img=32]res://Assets/UI/keyboard_e.png[/img] to chop"

		GameManager.Item.STONE:
			return "Press [img=32]res://Assets/UI/keyboard_e.png[/img] to mine"

		_:
			return "Press [img=32]res://Assets/UI/keyboard_e.png[/img] to collect"

func _on_detection_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , get_hint(), false)

func _on_detection_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , get_hint(), true)


func interact() -> void:
	SignalBus.update_hint.emit(get_hint())

func drop() -> void:
	var item = ItemDrop.setup(drop_item, global_position, drop_amount, 200)

	get_tree().root.add_child(item)
	can_drop = false
