extends Node

signal inventory_updated

# Envanterdeki bütün kartlar
var owned_ability_cards: Array[ResourceCardData] = []

# Kuşanılan kartlar
var equipped_ability_cards: Array[ResourceCardData] = []

# İleride eşya ekleme için
var owned_items: Array = []

#başlangıçta kuşanma slotu sınırı(skill tree ile artacak)
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
         