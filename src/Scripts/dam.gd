extends Area2D
class_name Dam

@export var max_health: int = 100
@export var starting_health: int = 100
@export var health_loss_per_day: int = 25

@export var repair_amount: int = 25
@export var cost_exponent: float = 2.0

@export var base_wood_cost: int = 5
@export var base_stone_cost: int = 3

var is_destroyed: bool = false


func _ready() -> void:
	GameManager.dam_health = clamp(starting_health, 0, max_health)

	SignalBus.day_changed.connect(_on_day_changed)


func interact() -> void:
	try_repair()


func _on_day_changed(_day: int) -> void:
	if is_destroyed:
		return

	GameManager.dam_health -= health_loss_per_day
	GameManager.dam_health = max(GameManager.dam_health, 0)

	print(GameManager.dam_health)
	if GameManager.dam_health <= 0:
		destroy_dam()


func get_repair_cost() -> Dictionary:
	var damage_ratio: float = 1.0 - (float(GameManager.dam_health) / max_health)

	var multiplier: float = pow(1.0 + damage_ratio, cost_exponent)

	return {
		GameManager.Item.WOOD: ceil(base_wood_cost * multiplier),
		GameManager.Item.STONE: ceil(base_stone_cost * multiplier)
	}


func can_repair(cost: Dictionary) -> bool:
	if is_destroyed or GameManager.dam_health >= max_health:
		return false

	for resource in cost:
		if not GameManager.inv_has_item(resource, cost[resource]):
			return false

	return true


func try_repair() -> bool:
	if is_destroyed:
		return false

	if GameManager.dam_health >= max_health:
		return false

	var cost: Dictionary = get_repair_cost()
	print("Repair cost: ", cost)


	if not can_repair(cost):
		return false

	for resource in cost:
		GameManager.inv_remove_item(resource, cost[resource])

	GameManager.dam_health = min(GameManager.dam_health + repair_amount, max_health)

	return true


func destroy_dam() -> void:
	if is_destroyed:
		return

	is_destroyed = true
	GameManager.dam_health = 0

	# - Trigger game over
	if not GameManager.is_day_started:
		await SignalBus.day_started
	
	await get_tree().create_timer(0.5).timeout

	GameManager.game_over("FLOODED")

func get_health() -> int:
	return GameManager.dam_health


func get_health_ratio() -> float:
	return float(GameManager.dam_health) / max_health


func _on_detection_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , false)

func _on_detection_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , true)
