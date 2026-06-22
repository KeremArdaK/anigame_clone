extends Resource
class_name ResourceCardData

@export var card_name: String
@export_multiline var card_description: String
@export var card_texture: Texture2D
@export var rarity: CardData.Rarity
@export_multiline var flavor_text: String




@export var innate_effects: Array[StatusEffect] = [] 


@export var on_hit_effects: Array[StatusEffect] = []