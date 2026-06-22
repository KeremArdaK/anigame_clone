extends Node


var canvas_layer: CanvasLayer
var container: VBoxContainer

func _ready():

	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100 
	add_child(canvas_layer)
	

	container = VBoxContainer.new()


	container.set_anchors_preset(Control.PRESET_CENTER_TOP)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	

	container.add_theme_constant_override("separation", 10)
	

	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_top", 30)
	

	margin.add_child(container)
	canvas_layer.add_child(margin)


func show_message(text: String, accent_color: Color = Color.WHITE):

	var sb = StyleBoxFlat.new()

	sb.bg_color = Color(0, 0, 0, 0.7) 
	

	sb.border_width_bottom = 3
	sb.border_width_top = 3
	sb.border_width_left = 3
	sb.border_width_right = 3

	sb.border_color = accent_color 
	

	sb.corner_radius_top_left = 8
	sb.corner_radius_top_right = 8
	sb.corner_radius_bottom_left = 8
	sb.corner_radius_bottom_right = 8
	

	sb.set_content_margin_all(15) 
	

	

	


	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER

	hbox.modulate.a = 0 
	

	var panel = PanelContainer.new()

	panel.add_theme_stylebox_override("panel", sb)
	

	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	label.add_theme_color_override("font_color", accent_color)


	

	panel.add_child(label)
	hbox.add_child(panel)
	container.add_child(hbox)
	

	var tween = create_tween()

	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	
	tween.tween_property(hbox, "modulate:a", 1.0, 0.3)
	tween.tween_interval(2.5)
	tween.tween_property(hbox, "modulate:a", 0.0, 0.8)
	tween.tween_callback(hbox.queue_free)
