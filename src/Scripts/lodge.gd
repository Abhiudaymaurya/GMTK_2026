extends Node2D

var max_tier: int = 3

var upgrade_costs := [
	{},
	{GameManager.Item.WOOD: 10, GameManager.Item.STONE: 5},
	{GameManager.Item.WOOD: 20, GameManager.Item.STONE: 10},
	{GameManager.Item.WOOD: 25, GameManager.Item.STONE: 20},
]

func _get_upgrade_hint() -> String:
	if GameManager.lodge_tier >= max_tier:
		return "Lodge Level: %d\nMAXED" % GameManager.lodge_tier

	var cost: Dictionary = upgrade_costs[GameManager.lodge_tier + 1]
	var hint: String = "Lodge Level: %d\nPress [img=32]res://Assets/UI/keyboard_e.png[/img] to upgrade lodge\nCost: " % (GameManager.lodge_tier + 1)

	for resource in cost:
		var amount: int = cost[resource]
		hint += "[img=32]%s[/img] : %d " % [_get_item_icon(resource), amount]

	return hint

func _get_item_icon(item: GameManager.Item) -> String:
	match item:
		GameManager.Item.WOOD:
			return "res://Assets/UI/wod.png"
		GameManager.Item.STONE:
			return "res://Assets/UI/ston.png"

	return ""

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
	
	EnvironmentManager.play_confetti();
	GameManager.lodge_tier += 1
	SignalBus.lodge_upgraded.emit(GameManager.lodge_tier)
	
	return true

func interact() -> void:
	try_upgrade()
	SignalBus.update_hint.emit(_get_upgrade_hint())

func _on_detection_box_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , _get_upgrade_hint(), false)

func _on_detection_box_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SignalBus.context_update.emit(self , _get_upgrade_hint(), true)
