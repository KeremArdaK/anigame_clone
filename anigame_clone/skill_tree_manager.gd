extends Node2D

var node_dictionary = {}
var prerequisites = {}
var lines_data = []

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame 
	

	find_all_talents(self)
	

	build_prerequisites()
	

	for node_id in node_dictionary:
		draw_connections(node_dictionary[node_id])
		

	update_tree_visuals()

func find_all_talents(current_node: Node) -> void:
	for child in current_node.get_children():
		if child is TalentNode and child.talent_data != null:
			node_dictionary[child.talent_data.id] = child

			child.talent_clicked.connect(_on_talent_node_clicked)
		find_all_talents(child)

func build_prerequisites() -> void:
	for t_id in node_dictionary:
		prerequisites[t_id] = []
		
	for parent_id in node_dictionary:
		var parent_node = node_dictionary[parent_id]
		for child_res in parent_node.talent_data.unlock_talents:
			if child_res and prerequisites.has(child_res.id):
				prerequisites[child_res.id].append(parent_id)


func is_talent_available(t_id: String) -> bool:
	if GameManager.unlocked_talents.has(t_id):
		return true

	if prerequisites[t_id].is_empty():
		return true

	for parent_id in prerequisites[t_id]:
		if GameManager.unlocked_talents.has(parent_id):
			return true
	return false

func _on_talent_node_clicked(talent_node: TalentNode) -> void:
	var data = talent_node.talent_data
	

	if GameManager.unlocked_talents.has(data.id):
		print("Bu yetenek zaten sınırlarına ulaştı, açık!")
		return
		

	if not is_talent_available(data.id):
		print("Kader bağları henüz bu yeteneğe uzanmadı! Önceki yetenekleri açmalısın.")
		return
		

	if CurrencyManager.prestige_points < data.cost:
		print("Yetersiz Prestij Puanı! Gereken: ", data.cost, " | Sende olan: ", CurrencyManager.prestige_points)
		return
		

	CurrencyManager.prestige_points -= data.cost

	CurrencyManager.shards_updated.emit(CurrencyManager.card_shards) 
	
	GameManager.unlocked_talents.append(data.id)
	

	GameManager.unlocked_talents.append(data.id)


	GameManager.rebuild_talent_buffs() 

	if SafeManagerHasFunction("save_game"):
		SaveManager.save_game()
		
	print(data.talent_name, " başarıyla açıldı!")
	update_tree_visuals()


func update_tree_visuals() -> void:

	for t_id in node_dictionary:
		var node = node_dictionary[t_id]
		var is_unlocked = GameManager.unlocked_talents.has(t_id)
		var is_available = is_talent_available(t_id)
		node.update_visual_state(is_unlocked, is_available)
		

	for line_info in lines_data:
		var line = line_info["line"]
		var p_id = line_info["parent_id"]
		var c_id = line_info["child_id"]
		
		if GameManager.unlocked_talents.has(p_id) and GameManager.unlocked_talents.has(c_id):
			line.default_color = Color(1.0, 0.85, 0.3)
			line.width = 5
		elif GameManager.unlocked_talents.has(p_id):
			line.default_color = Color(0.7, 0.7, 0.7)
			line.width = 4
		else:
			line.default_color = Color(0.15, 0.15, 0.15)
			line.width = 3

func draw_connections(parent_node: TalentNode) -> void:
	var parent_id = parent_node.talent_data.id
	for unlocked_resource in parent_node.talent_data.unlock_talents:
		if unlocked_resource and node_dictionary.has(unlocked_resource.id):
			var child_node = node_dictionary[unlocked_resource.id]
			
			var line = Line2D.new()
			line.top_level = true 
			
			var p_center = parent_node.global_position + (parent_node.size / 2.0)
			var c_center = child_node.global_position + (child_node.size / 2.0)
			
			line.add_point(p_center)
			line.add_point(c_center)
			line.z_index = -1 
			
			add_child(line)
			

			lines_data.append({
				"line": line,
				"parent_id": parent_id,
				"child_id": unlocked_resource.id
			})


func SafeManagerHasFunction(_func_name: String) -> bool:
	return has_node("/root/SaveManager") and "save_game" in SaveManager

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/god_menu.tscn")
