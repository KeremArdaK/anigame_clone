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
@onready var result_label = %ResultLabel
func _ready():
    buy_button.pressed.connect(_on_buy_button_pressed)

func _on_buy_button_pressed():
    #birinci aşama kontrol
    if CurrencyManager.card_shards < PACK_PRICE:
        result_label.text = "Not enough shards! You need %d." % PACK_PRICE
    
    #iknici aşama ödeme
    CurrencyManager.spend_shards(PACK_PRICE)

    #üçüncü aşama RNG
    var drop_count = randi_range(1, 3)
    var pulled_card_names: Array[String] = []

    #dördüncü aşama, çekiliş
    for i in range(drop_count):
        var random_index = randi() % shop_card_pool.size()
        var pulled_card = shop_card_pool[random_index]

        InventoryManager.owned_ability_cards.append(pulled_card)

        pulled_card_names.append(pulled_card.card_name)
    
    result_label.text = "Pack Opened! You got: " + ", ".join(pulled_card_names)

