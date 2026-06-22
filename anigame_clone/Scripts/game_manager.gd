extends Node


signal prestige_performed

var current_stage: int = 1
var defeated_enemies_on_current_stage: int = 0
var total_enemies_defeated: int = 0
var enemies_defeated_on_this_run: int = 0
var highest_stage: int = 1
var unlocked_talents: Array = []

var talent_damage_modifier: float = 0.0
var talent_defense_modifier: float = 0.0
var talent_prestige_multiplier: float = 1.0

func do_prestige():

	if highest_stage < 10:
		PopupManager.show_message("You must reach Stage 10 to Prestige!", Color.RED)
		return
		

	var earned_points = floor(highest_stage / 10.0)
	

	CurrencyManager.add_prestige_points(earned_points)
	

	current_stage = 1
	highest_stage = 1
	defeated_enemies_on_current_stage = 0
	enemies_defeated_on_this_run = 0
	

	CurrencyManager.card_shards = 0
	CurrencyManager.shards_updated.emit(0)
	

	InventoryManager.owned_ability_cards.clear()
	InventoryManager.equipped_ability_cards.clear()
	InventoryManager.inventory_updated.emit()

	SaveManager.save_game()
	

	PopupManager.show_message("Prestiged! Gained " + str(earned_points) + " Prestige Points.", Color.PURPLE)
	

	prestige_performed.emit()

func rebuild_talent_buffs() -> void:

	talent_damage_modifier = 0.0
	talent_defense_modifier = 0.0
	talent_prestige_multiplier = 1.0
	

	for talent_id in unlocked_talents:
		var path = "res://Talents/" + talent_id + ".tres"
		

		if ResourceLoader.exists(path):
			var resource = load(path) as TalentResource
			if resource:
				_apply_individual_buff(resource)
				
	print("Yetenek Buffları Başarıyla Güncellendi!")
	print("Bonus Hasar: %", talent_damage_modifier, " | Bonus Defans: %", talent_defense_modifier)


func _apply_individual_buff(resource: TalentResource) -> void:

	match resource.id:
		"berserk":
			talent_damage_modifier += resource.effect_value
		"defensive_aura":
			talent_defense_modifier += resource.effect_value
		"fortune":

			talent_prestige_multiplier += (resource.effect_value / 100.0)
		"perserverance":

			talent_damage_modifier += resource.effect_value