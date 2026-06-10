extends TextureButton
class_name AbilityCardSlot

@onready var icon = %AbilityIcon
@onready var card_name = %AbilityName

var current_card_data: ResourceCardData

#data driven ui
func render_slot(data: ResourceCardData):
	current_card_data = data
	#icon.texture = data.icon
	card_name.text = data.card_name
