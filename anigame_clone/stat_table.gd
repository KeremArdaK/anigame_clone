extends Panel

@onready var stat_label: RichTextLabel = %RichTextLabel

func _ready() -> void:

	hide()


func update_and_show_stats() -> void:
	var stats_text = "[center][b]--- KULE SİCİLİ ---[/b][/center]\n\n"


	stats_text += "[color=gold][b]-- İLERLEME & EKONOMİ --[/b][/color]\n"
	stats_text += "Zirve Seviyesi (Current Stage): " + str(GameManager.current_stage) + "\n"
	stats_text += "Kart Parçaları (Shards): " + str(CurrencyManager.card_shards) + "\n"
	stats_text += "Prestij Puanı (PP): " + str(CurrencyManager.prestige_points) + "\n"

	stats_text += "Toplam Prestij Atma Sayısı: " + str(GameManager.get("prestige_count") if "prestige_count" in GameManager else 0) + "\n\n"


	stats_text += "[color=tomato][b]-- SAVAŞ MODİFİYELERİ --[/b][/color]\n"
	stats_text += "Yetenek Hasar Çarpanı: %" + str(GameManager.talent_damage_modifier) + "\n"
	stats_text += "Yetenek Defans Çarpanı: %" + str(GameManager.talent_defense_modifier) + "\n"
	stats_text += "Prestij PP Kazanım Çarpanı: " + str(GameManager.talent_prestige_multiplier) + "x\n\n"


	stats_text += "[color=cyan][b]-- KART BİLGİLERİ --[/b][/color]\n"
	stats_text += "Maksimum Ekipman Slotu: " + str(InventoryManager.max_equip_slots) + "\n"
	stats_text += "Koleksiyondaki Kart Sayısı: " + str(InventoryManager.owned_ability_cards.size()) + "\n"
	stats_text += "Aktif Kuşanılan Kartlar: " + str(InventoryManager.equipped_ability_cards.size()) + "\n\n"


	var unlocked_count = GameManager.unlocked_talents.size()
	stats_text += "[color=lightgreen][b]-- KİLİDİ AÇILAN KADERLER (" + str(unlocked_count) + ") --[/b][/color]\n"
	if unlocked_count == 0:
		stats_text += "Henüz hiçbir yetenek açılmadı...\n"
	else:
		for talent_id in GameManager.unlocked_talents:
			stats_text += " > " + talent_id + "\n"
			
	stats_text += "\n[color=gray]Sistem saati: " + Time.get_time_string_from_system() + "[/color]"


	stat_label.text = stats_text
	

	show()

func _input(event: InputEvent) -> void:


	if event.is_action_pressed("ui_focus_next"):
		if visible:
			hide()
		else:
			update_and_show_stats()