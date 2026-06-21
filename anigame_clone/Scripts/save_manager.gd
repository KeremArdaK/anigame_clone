extends Node

const SAVE_FILE = "user://idling_tower_save.save"

func _ready() -> void:
    get_tree().set_auto_accept_quit(false)
    
    # Auto-save için bir Timer oluşturup başlatıyoruz (Her 60 saniyede bir)
    var auto_save_timer = Timer.new()
    auto_save_timer.wait_time = 60.0 
    auto_save_timer.autostart = true
    auto_save_timer.timeout.connect(_on_auto_save_timeout)
    add_child(auto_save_timer)

# İşletim sisteminden veya motordan gelen bildirimleri dinleyen fonksiyon
func _notification(what: int) -> void:
    if what == NOTIFICATION_WM_CLOSE_REQUEST:
        print("Kapanma isteği algılandı! Son veriler kurtarılıyor...")
        save_game()
        get_tree().quit() # Kayıt bittikten sonra oyunu güvenle kapat


func save_game():
    var save_dict = {
        "shards": CurrencyManager.card_shards,
        "prestige_points": CurrencyManager.prestige_points,
        "max_equip_slots": InventoryManager.max_equip_slots,
        "current_stage": GameManager.current_stage,
        "owned_cards_paths": [],
        "equipped_cards_paths": [],
        "unlocked_talents": GameManager.unlocked_talents
    }

    # Sahip olunan kartların dosya yolunu listeye ekliyoruz
    for card in InventoryManager.owned_ability_cards:
        save_dict["owned_cards_paths"].append(card.resource_path)
        
    # Kuşanılmış kartların dosya yollarını listeye ekliyoruz
    for card in InventoryManager.equipped_ability_cards:
        save_dict["equipped_cards_paths"].append(card.resource_path)

    var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
    file.store_var(save_dict)
    file.close()
    print("oyun kaydedildi!")

func load_game():
    if not FileAccess.file_exists(SAVE_FILE):
        print("kayıt dosyası bulunamadı. yeni oyun başlıyor")
        return
    
    var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
    var saved_data = file.get_var()

    # Parayı geri yükle ve UI'yi güncellemek için sinyali tetikle
    CurrencyManager.card_shards = saved_data["shards"]
    CurrencyManager.shards_updated.emit(CurrencyManager.card_shards) 

    # Açılmış yetenekleri kayıt dosyasından geri yüklüyoruz
    if saved_data.has("unlocked_talents"):
        GameManager.unlocked_talents = saved_data["unlocked_talents"]
    else:
        # Eğer oyuncunun bilgisayarında eski bir kayıt dosyası varsa ve içinde henüz 
        # "unlocked_talents" anahtarı yoksa, oyunun çökmemesi için temiz, boş bir dizi tanımlıyoruz.
        GameManager.unlocked_talents = []

    # Envanter sınırını geri yükle
    InventoryManager.max_equip_slots = saved_data["max_equip_slots"]
    
    # Kart listelerini temizle ve dosya yollarından tekrar yükle
    InventoryManager.owned_ability_cards.clear()
    for path in saved_data["owned_cards_paths"]:
        var loaded_card = load(path) as ResourceCardData
        if loaded_card:
            InventoryManager.owned_ability_cards.append(loaded_card)

    InventoryManager.equipped_ability_cards.clear()
    for path in saved_data["equipped_cards_paths"]:
        var loaded_card = load(path) as ResourceCardData
        if loaded_card:
            InventoryManager.equipped_ability_cards.append(loaded_card)
    
    if saved_data.has("current_stage"):
        GameManager.current_stage = saved_data["current_stage"]

    print("Oyun başarıyla yüklendi!")

    if saved_data.has("unlocked_talents"):
        GameManager.unlocked_talents = saved_data["unlocked_talents"]
	    # İŞTE BURASI: Kayıt dosyasından ID'ler yüklenir yüklenmez çarpanları inşa et!
        GameManager.rebuild_talent_buffs() 
    else:
        GameManager.unlocked_talents = []

func _on_auto_save_timeout() -> void:
    print("Otomatik kayıt alınıyor...")
    save_game()