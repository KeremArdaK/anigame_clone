extends Resource
class_name ResourceCardData

@export var card_name: String
@export var card_description: String
@export var card_texture: Texture2D
@export var rarity: CardData.Rarity

@export var effects_to_apply: Array[StatusEffect] = [] #Bu kartın saldırısı başarılı olduğunda rakibe uygulanacak efektler. Örneğin burn, poison, leech gibi.