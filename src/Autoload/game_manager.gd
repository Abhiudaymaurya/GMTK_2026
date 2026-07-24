extends Node

var time: float
var day: int

enum Item {
	WOOD,
	STONE,
	FOOD,
	WATER
}

var player_inventory: Dictionary[Item, int] = {}

# func _process(delta):
# 	print(player_inventory)

func _ready() -> void:
	for item in Item.values():
		player_inventory[item] = 0


func inv_add_item(item: Item, amount: int = 1) -> void:
	player_inventory[item] += amount


func inv_remove_item(item: Item, amount: int = 1) -> bool:
	if player_inventory[item] < amount:
		return false

	player_inventory[item] -= amount
	return true


func inv_has_item(item: Item, amount: int = 1) -> bool:
	return player_inventory[item] >= amount