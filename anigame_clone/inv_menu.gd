extends MarginContainer
class_name InventoryMenu

const SLOT_SCENE = preload("res://Scenes/Menus/ability_card_slot.tscn")

@onready var card_grid = %CardGrid
@onready var search_bar = %SearchBar

@onready var tooltip_panel = %ToolTipPanel
@onready var tooltip_stats = %StatsLabel
@onready var tooltip_title = %TitleLabel
@onready var tooltip_lore = %LoreLabel
@onready var equip_button = %EquipButton
@onready var close_button = %CloseButton

var filtered_pool: Array[ResourceCardData] = []
var currently_viewed_card: ResourceCardData = null # O an Tooltip'te açık olan kart

func _ready():
	search_bar.text_changed.connect(_on_search_text_changed)
	equip_button.pressed.connect(_on_equip_button_pressed)
	close_button.pressed.connect(_on_close_button_pressed)

	# 1. ÖNCE VERİYİ HAZIRLA: Varsayılan kartı ekle
	if InventoryManager.owned_ability_cards.is_empty():
		InventoryManager.owned_ability_cards.append(preload("res://Ability Cards/flamingpunch.tres"))

	# 2. HAVUZU OLUŞTUR
	filtered_pool = InventoryManager.owned_ability_cards.duplicate()

	# 3. EN SON EKRANI ÇİZ (Veriler hazır olduktan sonra)
	refresh_inventory_view()
	

func refresh_inventory_view():
	if search_bar.text.is_empty():
		filtered_pool = InventoryManager.owned_ability_cards.duplicate() as Array[ResourceCardData]
	
	# ızgaradaki her kartı temizle
	for child in card_grid.get_children():
		child.queue_free()

	# filtrelenmiş havuzdaki her kart verisi için bir slot oluştur
	for card_data in filtered_pool:
		var slot_instance = SLOT_SCENE.instantiate()
		card_grid.add_child(slot_instance)
		slot_instance.render_slot(card_data)
		
		# SİNYAL BAĞLANTISI
		if not slot_instance.is_connected("slot_clicked", Callable(self, "_on_card_slot_clicked")):
			slot_instance.slot_clicked.connect(_on_card_slot_clicked)

func _on_card_slot_clicked(card_data: ResourceCardData):
	currently_viewed_card = card_data

	tooltip_title.text = card_data.card_name
	tooltip_stats.text = card_data.card_description
	tooltip_lore.text = "[i]" + card_data.flavor_text + "[/i]"

	if InventoryManager.equipped_ability_cards.has(card_data):
		equip_button.text = "Unequip"
		equip_button.disabled = false
	else:
		equip_button.text = "Equip"
		equip_button.disabled = false

	tooltip_panel.show()

func _on_equip_button_pressed():
	if currently_viewed_card == null: return
	
	# Eğer kart zaten kuşanılmışsa, onu çıkart (Unequip)
	if InventoryManager.equipped_ability_cards.has(currently_viewed_card):
		InventoryManager.unequip_card(currently_viewed_card)
		equip_button.text = "Equip"
		print("Unequipped ", currently_viewed_card.card_name)
	else:
		# Kart kuşanılmamışsa, kuşanmayı dene (Equip)
		var success = InventoryManager.equip_card(currently_viewed_card)
		if success:
			print("Equipped ", currently_viewed_card.card_name)
			equip_button.text = "Unequip"
		else:
			print("Slotlar Dolu!")
			# İstersen burada tooltip üzerinden oyuncuya kırmızı bir "Equip slots full!" uyarısı da gösterebilirsin.
func _on_close_button_pressed():
	tooltip_panel.hide()
	currently_viewed_card = null

func _on_search_text_changed(new_text: String):
	if new_text.is_empty():
		#arama çubuğu boşsa tüm kartları göster
		filtered_pool = InventoryManager.owned_ability_cards.duplicate() as Array[ResourceCardData]
	else:
		#kartları filtrele
		filtered_pool = InventoryManager.owned_ability_cards.filter(
			func(card): return new_text.to_lower() in card.card_name.to_lower()
		) as Array[ResourceCardData]

	refresh_inventory_view()
