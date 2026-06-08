extends Node

var cards : Dictionary = {}

func _ready() -> void:
	load_all_cards("res://Cards")

func load_all_cards(path: String):
	var dir = DirAccess.open(path)
	
	if dir:
		for file_name in dir.get_files():
			if file_name.ends_with(".tres") or file_name.ends_with(".tres.remap"):
				var clean_name = file_name.replace(".remap","")
				
				var resource = load(path + "/" + clean_name)
				
				if resource is CardData:
					var card_id = clean_name.replace(".tres","").to_lower()
					cards[card_id] = resource
		print("Kart veritabanı yüklendi. Toplam kart: ", cards.size())
	else:
		print("Hata: ", path, " bulunamadı.")

func get_card(id: String) -> CardData:
	id = id.to_lower()
	if cards.has(id):
		return cards[id]
	else:
		print("hata: ", id, " bulunamadı.")
		return null
