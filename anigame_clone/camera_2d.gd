extends Camera2D

var is_dragging := false
var last_mouse_pos := Vector2.ZERO




func _unhandled_input(event: InputEvent) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true

				last_mouse_pos = event.position 
			else:
				is_dragging = false
				

	if event is InputEventMouseMotion and is_dragging:
		var drag_delta = last_mouse_pos - event.position
		


		
		position += drag_delta
		last_mouse_pos = event.position
