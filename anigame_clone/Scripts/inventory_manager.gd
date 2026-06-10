extends Node

#envanterdeki bütün kartlar
var owned_ability_cards = []

#kuşanılan kartlar
var equipped_ability_cards = []

#ileride eşya ekleme ve çıkarma fonksiyonları eklenebilir, şimdiden hazırlığını yapalım
var owned_items = []

#başlangıçta kuşanma slotu sınırı(skill tree ile artacak)
var max_equip_slots: int = 3

func equip_card(card: ResourceCardData) -> bool:
    if equipped_ability_cards.size() >= max_equip_slots:
        print("ekipman slotu dolu")
        return false

    if not equipped_ability_cards.has(card):
        equipped_ability_cards.append(card)
        return true
    return false

func unequip_card(card: ResourceCardData):
    if equipped_ability_cards.has(card):
        equipped_ability_cards.erase(card)
         