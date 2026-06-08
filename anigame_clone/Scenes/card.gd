extends Control

@export var card_data: CardData

@onready var card_template: TextureRect = $CardTemplate
@onready var card_name: Label = $CardName
@onready var card_illustration: TextureRect = $CardIllustration
@onready var stats_container: HBoxContainer = $StatsContainer
@onready var attack_lbl: Label = $StatsContainer/AttackLbl
@onready var health_lbl: Label = $StatsContainer/HealthLbl

func _ready() -> void:
	if card_data:
		render_data(card_data)

func render_data(data: CardData):
	card_data = data
	
	card_name.text = card_data.card_name
	card_illustration.texture = card_data.card_texture
	attack_lbl.text = str(card_data.attack_damage)
	health_lbl.text = str(card_data.max_health)
	
	match card_data.rarity:
			CardData.Rarity.COMMON: 
				card_template.texture = preload("res://Textures/cards/common_card_empty.png")
			CardData.Rarity.RARE: 
				card_template.texture = preload("res://Textures/cards/rare_card_empty.png")
			CardData.Rarity.LEGENDARY: 
				card_template.texture = preload("res://Textures/cards/legendary_card_empty.png")
			CardData.Rarity.MYTHIC: 
				card_template.texture = preload("res://Textures/cards/mythic_card_empty.png")


func update_health_ui(new_hp: int):
	health_lbl.text = str(clamp(new_hp, 0, card_data.max_health))
