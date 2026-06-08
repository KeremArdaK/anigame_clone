extends Resource
class_name CardData

#--Enum'lar--
enum AttackType {FIRE, WATER, EARTH, AIR, NONE} 
enum Rarity {COMMON, RARE, LEGENDARY, MYTHIC}

@export var card_name: String = "Yeni Kart"
@export var card_description: String = ""
@export var card_texture: Texture2D

@export var attack_damage: int = 0
@export var max_health: int = 0
@export var attack_type: AttackType
@export var rarity: Rarity
