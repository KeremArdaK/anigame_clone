extends Resource
class_name TalentResource

enum TalentType { PASSIVE, CONDITIONAL }

@export var id: String # Örn: "azim_1", "hasar_5" (Kayıt sistemi için şart!)
@export var talent_name: String
@export_multiline var description: String
@export var talent_icon: CompressedTexture2D

@export var type: TalentType
@export var effect_value: float # Yüzde kaçlık bir etki vereceği (Örn: 5.0)
@export var cost: int = 1 # Kaç Prestige Point isteyeceği

# Bu yetenek açıldığında, hangi yeteneklerin kilitleri kalkacak?
@export var unlock_talents: Array[TalentResource]