extends Node2D

var max_tier: int = 3

var upgrade_costs := [
	{},
	{GameManager.Item.WOOD: 10, GameManager.Item.STONE: 5},
	{GameManager.Item.WOOD: 20, GameManager.Item.STONE: 10},
	{GameManager.Item.WOOD: 25, GameManager.Item.STONE: 20},
]

func _process(_delta: float) -> void:
	$resources.text = str("resources: ", GameManager.player_inventory)

	if GameManager.lodge_tier >= max_tier:
		$cost.text = "MAXED LVL"
	else:
		$cost.text = str("cost: ", upgrade_costs[GameManager.lodge_tier + 1])


func can_upgrade() -> bool:
	var cost = upgrade_costs[GameManager.lodge_tier + 1]

	for resource in cost:
		if not GameManager.inv_has_item(resource, cost[resource]):
			return false

	return true

func try_upgrade() -> bool:
	if GameManager.lodge_tier >= max_tier:
		SignalBus.upgrade_failed.emit("max level already")
		return false
	if not can_upgrade():
		SignalBus.upgrade_failed.emit("not enough resources")
		return false

	var cost = upgrade_costs[GameManager.lodge_tier + 1]
	for resource in cost:
		GameManager.inv_remove_item(resource, cost[resource])
	
	GameManager.lodge_tier += 1
	SignalBus.lodge_upgraded.emit(GameManager.lodge_tier)
	
	return true

func interact() -> void:
	try_upgrade()

func _on_button_2_pressed() -> void:
	GameManager.inv_add_item(GameManager.Item.WOOD, 1)

func _on_button_3_pressed() -> void:
	GameManager.inv_add_item(GameManager.Item.STONE, 1)


func _on_detection_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , false)

func _on_detection_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , true)
