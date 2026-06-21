extends Resource
class_name ResourceCardData

@export var card_name: String
@export_multiline var card_description: String
@export var card_texture: Texture2D
@export var rarity: CardData.Rarity
@export_multiline var flavor_text: String

# --- YENİ SİSTEM: Yetenek kartlarını da ikiye bölüyoruz! ---

# Kuşandığın an aktif olan pasifler (Örn: Defans, Doğuştan Leech)
@export var innate_effects: Array[StatusEffect] = [] 

# Vurduğunda rakibe geçenler (Örn: Zehir, Yanma, Körlük)
@export var on_hit_effects: Array[StatusEffect] = []