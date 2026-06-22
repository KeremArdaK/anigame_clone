extends Control

var display_health: int = 0
var health_tween: Tween

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
	
	display_health = data.max_health
	health_lbl.text = str(display_health)

func update_health_ui(new_hp: int):
	new_hp = max(0, new_hp)


	if health_tween and health_tween.is_valid():
		health_tween.kill()
		
	health_tween = create_tween()
	


	var is_damage = new_hp < display_health
	if is_damage:
		health_lbl.modulate = Color.RED
		health_tween.tween_property(health_lbl, "scale", Vector2(1.3, 1.3), 0.05)
	



	health_tween.tween_method(_animate_label_text, float(display_health), float(new_hp), 0.3)
	

	if is_damage:
		health_tween.tween_property(health_lbl, "scale", Vector2(1, 1), 0.1)
		health_tween.tween_property(health_lbl, "modulate", Color.WHITE, 0.1)
	

	display_health = new_hp


func _animate_label_text(value: float):

	health_lbl.text = str(int(round(value)))
