extends Camera2D

var is_dragging := false
var last_mouse_pos := Vector2.ZERO

# İleride sınırları zorlamak istersen haritaya bir limit koyabilirsin
# var pan_limit_x = Vector2(-2000, 2000) 

func _unhandled_input(event: InputEvent) -> void:
	# 1. Tıklama Kontrolü (Sürüklemeyi başlat/bitir)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				# Farenin ekrandaki mutlak pozisyonunu alıyoruz
				last_mouse_pos = event.position 
			else:
				is_dragging = false
				
	# 2. Fare Hareketi Kontrolü (Sürükleme anı)
	if event is InputEventMouseMotion and is_dragging:
		var drag_delta = last_mouse_pos - event.position
		
		# Eğer ileride zoom eklersen, kaydırma hızının bozulmaması için:
		# drag_delta *= (1.0 / zoom.x)
		
		position += drag_delta
		last_mouse_pos = event.position