extends Node

# Prestige atıldığında FightMenu'ye haber verecek sinyal
signal prestige_performed

var current_stage: int = 1
var defeated_enemies_on_current_stage: int = 0
var total_enemies_defeated: int = 0 # Bu kalıcı, sıfırlanmayacak!
var enemies_defeated_on_this_run: int = 0
var highest_stage: int = 1
var unlocked_talents: Array = []

var talent_damage_modifier: float = 0.0      # Örn: %50 hasar artışı için 50.0
var talent_defense_modifier: float = 0.0     # Örn: %20 defans artışı için 20.0
var talent_prestige_multiplier: float = 1.0  # Prestij puanı çarpanı

func do_prestige():
	# Oyuncu en azından 10. stage'e ulaşmış olmalı
	if highest_stage < 10:
		PopupManager.show_message("You must reach Stage 10 to Prestige!", Color.RED)
		return
		
	# Kazanılacak puan hesabı: Her 10 stage için 1 Prestige Puanı
	var earned_points = floor(highest_stage / 10.0)
	
	# 1. Kalıcı puanı CurrencyManager'a ekle
	CurrencyManager.add_prestige_points(earned_points)
	
	# 2. Mevcut koşu (Run) verilerini sıfırla
	current_stage = 1
	highest_stage = 1
	defeated_enemies_on_current_stage = 0
	enemies_defeated_on_this_run = 0
	
	# 3. Parayı (Card Shard) sıfırla
	CurrencyManager.card_shards = 0
	CurrencyManager.shards_updated.emit(0)
	
	# 4. Envanteri temizle (Verdiğin karara göre tam temizlik)
	InventoryManager.owned_ability_cards.clear()
	InventoryManager.equipped_ability_cards.clear()
	InventoryManager.inventory_updated.emit()
	# 5. Yeni durumu hemen diske kaydet
	SaveManager.save_game()
	
	# 6. Ekranda oyuncuyu ödüllendir
	PopupManager.show_message("Prestiged! Gained " + str(earned_points) + " Prestige Points.", Color.PURPLE)
	
	# 7. Savaş ekranının kendini yenilemesi için sinyali ateşle
	prestige_performed.emit()

func rebuild_talent_buffs() -> void:
	# Önce tüm havuzu sıfırla (Overlapping/Üst üste binme hatalarını önlemek için)
	talent_damage_modifier = 0.0
	talent_defense_modifier = 0.0
	talent_prestige_multiplier = 1.0
	
	# Açılmış tüm yetenek ID'lerini dönüyoruz
	for talent_id in unlocked_talents:
		var path = "res://Talents/" + talent_id + ".tres"
		
		# Dosya yolunun güvenliğini kontrol et
		if ResourceLoader.exists(path):
			var resource = load(path) as TalentResource
			if resource:
				_apply_individual_buff(resource)
				
	print("Yetenek Buffları Başarıyla Güncellendi!")
	print("Bonus Hasar: %", talent_damage_modifier, " | Bonus Defans: %", talent_defense_modifier)

# Yeteneğin türüne göre ilgili global değişkeni besleyen iç fonksiyon
func _apply_individual_buff(resource: TalentResource) -> void:
	# İster ID bazlı, ister ileride ekleyeceğin bir stat_type enum'ına göre ayırabilirsin:
	match resource.id:
		"berserk":
			talent_damage_modifier += resource.effect_value
		"defensive_aura":
			talent_defense_modifier += resource.effect_value
		"fortune":
			# % etkisini çarpana dönüştürüyoruz (Örn: etki 15 ise çarpan 1.15 olur)
			talent_prestige_multiplier += (resource.effect_value / 100.0)
		"perserverance":
			# Azim yeteneği için hangi statı beslemek istiyorsan:
			talent_damage_modifier += resource.effect_value