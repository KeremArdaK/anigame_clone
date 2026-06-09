extends Resource
class_name CardData

#--Enum'lar--
enum AttackType {NONE, FIRE, WATER, EARTH, AIR} 
enum Rarity {COMMON, RARE, LEGENDARY, MYTHIC}

@export var passive_effects: Array[StatusEffect] = [] #Kartın sahip olduğu pasif etkiler, örneğin burn, poison, leech gibi.
@export var card_name: String = "Yeni Kart"
@export var card_description: String = ""
@export var card_texture: Texture2D

@export var attack_damage: int = 0
@export var max_health: int = 0
@export var attack_type: AttackType
@export var rarity: Rarity
