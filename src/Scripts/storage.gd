extends Area2D

@export var base_storage_capacity: int = 25
@export var storage_capacity_per_tier: int = 20

var lodge_tier: int = 0


func _ready() -> void:
	SignalBus.lodge_upgraded.connect(_on_lodge_upgraded)


func interact() -> void:
	try_store()
	SignalBus.update_hin.emit(get_hint())


func try_store() -> bool:
	var storage_space: int = get_storage_capacity() - GameManager.stored_food
	var food_count: int = GameManager.player_inventory[GameManager.Item.FOOD]

	if storage_space <= 0 or food_count <= 0:
		return false

	var amount_to_store: int = mini(food_count, storage_space)

	GameManager.inv_remove_item(GameManager.Item.FOOD, amount_to_store)
	GameManager.stored_food += amount_to_store

	return true


func get_storage_capacity() -> int:
	return base_storage_capacity + (
		lodge_tier * storage_capacity_per_tier
	)


func get_hint() -> String:
	var capacity: int = get_storage_capacity()
	var stored: int = GameManager.stored_food

	return "Storage: %d/%d\nPress [img=32]res://Assets/UI/keyboard_e.png[/img] to store [img=32]res://food.svg[/img]" % [
		stored,
		capacity
	]


func _on_lodge_upgraded(tier: int) -> void:
	lodge_tier = tier


func _on_detection_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , get_hint(), false)


func _on_detection_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , get_hint(), true)