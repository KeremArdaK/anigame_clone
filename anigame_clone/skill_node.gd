extends TextureButton
class_name TalentNode

# Tasarladığın o Resource dosyasını Inspector'dan buraya sürükleyeceğiz
@export var talent_data: TalentResource
@onready var line_2d = $Line2D

func _ready() -> void:
    if get_parent() is TalentNode:
        line_2d.add_point(global_position + size/2)
        line_2d.add_point(get_parent().global_position + size/2)
        
    # Eğer resource bağlandıysa, ikonunu otomatik olarak butona ata
    if talent_data and talent_data.talent_icon:
        texture_normal = talent_data.talent_icon
		
		# İsteğe bağlı: Butonun üzerine gelince ismini göstersin
        tooltip_text = talent_data.talent_name + "\nCost: " + str(talent_data.cost) + " PP"
		
	# Tıklanma sinyalini bağlıyoruz (Mantığını 3. aşamada yazacağız)
    pressed.connect(_on_talent_pressed)

func _on_talent_pressed():
	# Harita yöneticisine "Bana tıklandı!" diye haber vereceğiz
	# Şimdilik sadece test için print koyalım:
    print(talent_data.talent_name + " yeteneğine tıklandı!")