extends TextureButton
class_name TalentNode

@export var talent_data: TalentResource


signal talent_clicked(node_reference: TalentNode)

func _ready() -> void:
	if talent_data and talent_data.talent_icon:
		texture_normal = talent_data.talent_icon
		_update_tooltip()
		
	pressed.connect(_on_talent_pressed)

func _on_talent_pressed() -> void:
	talent_clicked.emit(self)


func _update_tooltip() -> void:
	tooltip_text = talent_data.talent_name + "\nCost: " + str(talent_data.cost) + " PP\n" + talent_data.description


func update_visual_state(is_unlocked: bool, is_available: bool) -> void:
	if is_unlocked:
		modulate = Color(1, 1, 1, 1)
	elif is_available:
		modulate = Color(0.6, 0.6, 0.6, 1)
	else:
		modulate = Color(0.2, 0.2, 0.2, 1)
