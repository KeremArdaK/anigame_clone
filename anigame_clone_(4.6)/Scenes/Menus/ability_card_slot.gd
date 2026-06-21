extends TextureButton
class_name AbilityCardSlot

@onready var icon = %AbilityIcon
@onready var card_name = %AbilityName

signal slot_clicked(card_data: ResourceCardData)

var current_card_data: ResourceCardData

#data driven ui
func render_slot(data: ResourceCardData):
	current_card_data = data
	icon.texture = data.card_texture
	card_name.text = data.card_name

func _pressed() -> void:
	slot_clicked.emit(current_card_data)