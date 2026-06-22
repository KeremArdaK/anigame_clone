extends Resource
class_name CardData


enum AttackType {NONE, FIRE, WATER, EARTH, AIR} 
enum Rarity {COMMON, RARE, LEGENDARY, MYTHIC}



@export var innate_effects: Array[StatusEffect] = []


@export var on_hit_effects: Array[StatusEffect] = []



@export var card_name: String = "Yeni Kart"
@export_multiline var card_description: String = ""
@export_multiline var flavor_text: String = ""
@export var card_texture: Texture2D

@export var attack_damage: int = 0
@export var max_health: int = 0
@export var attack_type: AttackType
@export var rarity: Rarity
