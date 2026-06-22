extends Resource
class_name TalentResource

enum TalentType { PASSIVE, CONDITIONAL }

@export var id: String
@export var talent_name: String
@export_multiline var description: String
@export var talent_icon: CompressedTexture2D

@export var type: TalentType
@export var effect_value: float
@export var cost: int = 1


@export var unlock_talents: Array[TalentResource]