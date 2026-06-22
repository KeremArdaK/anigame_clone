extends Node


signal shards_updated(new_amount: int)
signal prestige_updated(new_amount: int)

var card_shards: int = 0
var prestige_points: int = 100


func add_shards(amount: int):
	card_shards += amount
	shards_updated.emit(card_shards)
	

func spend_shards(amount: int) -> bool:
	if card_shards >= amount:
		card_shards -= amount
		shards_updated.emit(card_shards)
		return true
	else:
		return false



func add_prestige_points(amount: int):
	prestige_points += amount
	prestige_updated.emit(prestige_points)

func spend_prestige_points(amount: int) -> bool:
	if prestige_points >= amount:
		prestige_points -= amount
		prestige_updated.emit(prestige_points)
		return true
	return false