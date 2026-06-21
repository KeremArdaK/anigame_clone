extends Node2D

# Hangi ID'ye sahip yeteneğin haritada hangi pozisyonda durduğunu aklımızda tutacağız
var node_dictionary = {}
var connection_lines = []

func _ready() -> void:
	# 1. Aşama: Haritadaki tüm yetenekleri bul ve sözlüğe kaydet
	for child in get_children():
		if child is TalentNode and child.talent_data != null:
			node_dictionary[child.talent_data.id] = child
			
	# 2. Aşama: Kader ağlarını (çizgileri) ör
	for child in get_children():
		if child is TalentNode and child.talent_data != null:
			draw_connections(child)

func draw_connections(parent_node: TalentNode) -> void:
	# Bu yeteneğin açtığı diğer yetenekleri tarıyoruz
	for unlocked_resource in parent_node.talent_data.unlock_talents:
		if node_dictionary.has(unlocked_resource.id):
			var child_node = node_dictionary[unlocked_resource.id]
			
			# İki nokta arasına çizgi çek
			var line = Line2D.new()
			
			# İkonların sol üstünden değil, tam merkezinden çıkması için offset ekliyoruz.
			# Eğer ikonların 64x64 ise Vector2(32,32) yapabilirsin.
			var center_offset = parent_node.size / 2.0 
			
			line.add_point(parent_node.position + center_offset)
			line.add_point(child_node.position + center_offset)
			
			line.width = 4
			line.default_color = Color(0.3, 0.3, 0.3) # Henüz kilitli olduğu için sönük, koyu gri
			line.z_index = -1 # Çizgiler butonların altında kalsın
			
			add_child(line)
			connection_lines.append(line)