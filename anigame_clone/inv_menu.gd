extends MarginContainer

const SLOT_SCENE = preload("res://Scenes/Menus/ability_card_slot.tscn")

@onready var card_grid = %CardGrid
@onready var search_bar = %SearchBar

var filtered_pool: Array[ResourceCardData] = []

func _ready():
	search_bar.text_changed.connect(_on_search_text_changed)

	if InventoryManager.owned_ability_cards.is_empty():
		InventoryManager.owned_ability_cards.append(preload("res://Ability Cards/flamingpunch.tres"))

	filtered_pool = InventoryManager.owned_ability_cards.duplicate()

	refresh_inventory_view()

func refresh_inventory_view():
	#ızgaradaki her kartı temizle
	for child in card_grid.get_children():
		child.queue_free()

	#filtrelenmiş havuzdaki her kart verisi için bir slot oluştur
	for card_data in filtered_pool:
		var slot_instance = SLOT_SCENE.instantiate()
		card_grid.add_child(slot_instance)
		slot_instance.render_slot(card_data)

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
