extends Area2D

@export var base_storage_capacity: int = 5
@export var storage_capacity_per_tier: int = 5

var lodge_tier: int = 0


func _ready() -> void:
	SignalBus.lodge_upgraded.connect(_on_lodge_upgraded)


func interact() -> void:
	try_store()


func try_store() -> bool:
	if GameManager.stored_food >= get_storage_capacity():
		return false

	if not GameManager.inv_has_item(GameManager.Item.FOOD, 1):
		return false

	GameManager.inv_remove_item(GameManager.Item.FOOD, 1)
	GameManager.stored_food += 1

	return true


func get_storage_capacity() -> int:
	return base_storage_capacity + ((lodge_tier) * storage_capacity_per_tier)


func _on_lodge_upgraded(tier: int) -> void:
	lodge_tier = tier


func _on_detection_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , false)


func _on_detection_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , true)