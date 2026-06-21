extends Node

# Prestige atıldığında FightMenu'ye haber verecek sinyal
signal prestige_performed

var current_stage: int = 1
var defeated_enemies_on_current_stage: int = 0
var total_enemies_defeated: int = 0 # Bu kalıcı, sıfırlanmayacak!
var enemies_defeated_on_this_run: int = 0
var highest_stage: int = 1

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