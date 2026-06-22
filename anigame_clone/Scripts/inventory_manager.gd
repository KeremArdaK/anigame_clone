extends Node

signal inventory_updated


var owned_ability_cards: Array[ResourceCardData] = []


var equipped_ability_cards: Array[ResourceCardData] = []


var owned_items: Array = []


var max_equip_slots: int = 3

func equip_card(card: ResourceCardData) -> bool:
    if equipped_ability_cards.has(card):
        return false
    
    if equipped_ability_cards.size() >= max_equip_slots:
        var _removed_card = equipped_ability_cards.pop_front()
    
    equipped_ability_cards.append(card)
    PopupManager.show_message("Equipped: " + card.card_name, Color.FOREST_GREEN)
    return true
    
func unequip_card(card: ResourceCardData):
    if equipped_ability_cards.has(card):
        equipped_ability_cards.erase(card)
         