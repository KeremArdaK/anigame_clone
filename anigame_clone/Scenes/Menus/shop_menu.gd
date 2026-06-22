extends Control

const PACK_PRICE: int = 50

var shop_card_pool: Array[ResourceCardData] = [
	preload("res://Ability Cards/blinding_rage.tres"),
	preload("res://Ability Cards/blood_boil.tres"),
	preload("res://Ability Cards/burning_punch.tres"),
	preload("res://Ability Cards/eclipse.tres"),
	preload("res://Ability Cards/final_gambit.tres"),
	preload("res://Ability Cards/flamingpunch.tres"),
	preload("res://Ability Cards/kamikaze_protocol.tres"),
	preload("res://Ability Cards/noxious_fumes.tres"),
	preload("res://Ability Cards/phoenix_ash.tres"),
	preload("res://Ability Cards/poisoning_punch.tres"),
	preload("res://Ability Cards/radiant_armor.tres"),
	preload("res://Ability Cards/siphoning_aura.tres"),
	preload("res://Ability Cards/unbreakable_will.tres"),
	preload("res://Ability Cards/undying_menace.tres"),
	preload("res://Ability Cards/vampire's_vessel.tres"),
	preload("res://Ability Cards/venomous_blade.tres")
]

@onready var buy_button = %BuyButton
@onready var card_texture = %CardTexture

func _ready():
	buy_button.pressed.connect(_on_buy_button_pressed)

func _on_buy_button_pressed():

	if CurrencyManager.card_shards < PACK_PRICE:

		return


	CurrencyManager.spend_shards(PACK_PRICE)


	var drop_count = randi_range(1, 3)
	var pulled_card_names: Array[String] = []


	for i in range(drop_count):

		var roll = randf_range(0.0, 100.0)
		var target_rarity: CardData.Rarity
		

		if roll <= 60.0:
			target_rarity = CardData.Rarity.COMMON
		elif roll <= 94.9:
			target_rarity = CardData.Rarity.RARE
		elif roll <= 99.9:
			target_rarity = CardData.Rarity.LEGENDARY
		else:
			target_rarity = CardData.Rarity.MYTHIC
			

		var possible_cards = shop_card_pool.filter(func(card): return card.rarity == target_rarity)
		

		if possible_cards.is_empty():
		
			possible_cards = shop_card_pool.filter(func(card): return card.rarity == CardData.Rarity.COMMON)
			

		var random_index = randi() % possible_cards.size()
		var pulled_card = possible_cards[random_index]

		if InventoryManager.owned_ability_cards.has(pulled_card):
			var refund_shards = 150
			CurrencyManager.add_shards(refund_shards)
			pulled_card_names.append(pulled_card.card_name + " (Copy! +150 shards returned.)")
		else:
			InventoryManager.owned_ability_cards.append(pulled_card)
			pulled_card_names.append(pulled_card.card_name)
			InventoryManager.inventory_updated.emit()
	

	PopupManager.show_message("Pack Opened! You got:" + ", ".join(pulled_card_names), Color.ALICE_BLUE)
