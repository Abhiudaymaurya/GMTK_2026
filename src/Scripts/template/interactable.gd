extends StaticBody2D
class_name Interactable

@export var drop_item: GameManager.Item = GameManager.Item.WOOD
@export var drop_amount: int = 1

var can_drop: bool = true


func _ready() -> void:
	if drop_amount <= 0:
		push_error("invalid parms set in editor.")

	SignalBus.day_changed.connect(_on_day_changed)


func _on_day_changed(day: int) -> void:
	print("Day changed to: ", day)
	can_drop = true

func _on_detection_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , false)

func _on_detection_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , true)


func interact() -> void:
	if can_drop:
		drop()

func drop() -> void:
	var item = ItemDrop.setup(drop_item, global_position, drop_amount, 200)

	get_tree().root.add_child(item)
	can_drop = false
