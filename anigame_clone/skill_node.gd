extends TextureButton
class_name TalentNode

@export var talent_data: TalentResource

# Menajere "bana tıklandı" haberi göndermek için sinyal
signal talent_clicked(node_reference: TalentNode)

func _ready() -> void:
	if talent_data and talent_data.talent_icon:
		texture_normal = talent_data.talent_icon
		_update_tooltip()
		
	pressed.connect(_on_talent_pressed)

func _on_talent_pressed() -> void:
	talent_clicked.emit(self)

# Tooltip içeriğini dinamik hale getiriyoruz
func _update_tooltip() -> void:
	tooltip_text = talent_data.talent_name + "\nCost: " + str(talent_data.cost) + " PP\n" + talent_data.description

# Yeteneğin durumuna göre butonun rengini/görünümünü değiştirir
func update_visual_state(is_unlocked: bool, is_available: bool) -> void:
	if is_unlocked:
		modulate = Color(1, 1, 1, 1) # Tam parlak, açık renk
	elif is_available:
		modulate = Color(0.6, 0.6, 0.6, 1) # Satın alınabilir, biraz sönük gri
	else:
		modulate = Color(0.2, 0.2, 0.2, 1) # Tamamen kilitli, koyu karanlık
