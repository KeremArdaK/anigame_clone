extends MarginContainer

const CARD_SCENE = preload("res://Scenes/card.tscn")

var player_active_effects: Array[StatusEffect] = []
var enemy_active_effects: Array[StatusEffect] = []

@onready var player_side: VBoxContainer = $HBoxContainer/PlayerSide
@onready var enemy_side: VBoxContainer = $HBoxContainer/EnemySide
@onready var fight_button: Button = $HBoxContainer/LogSide/FightButton
@onready var battle_log: RichTextLabel = $HBoxContainer/LogSide/BattleLog
@onready var stage_info: Label = $StageInfo

var current_player_hp: int
var current_enemy_hp: int

var player_data: CardData
var enemy_data: CardData

var is_enemy_blinded: bool = false
var current_stage: int = 1

var active_player_card : Control
var active_enemy_card : Control

const ENEMY_POOL = [
	"skeleton", "goblin", "orc", "zombie", "wolf", "witch", 
	"vampire", "slime", "ghost", "demon"
]

# --- LOG YÖNETİM SİSTEMİ ---
var log_history: Array[String] = []
const MAX_LOG_LINES: int = 50

func _ready() -> void:
	# Yazı yenilendiğinde kaydırma çubuğunun hep en altta kalmasını garanti edelim
	battle_log.scroll_following = true 
	
	setup_initial_battlefield()
	fight_button.pressed.connect(_on_fight_button_pressed)

# --- ÖZEL LOG FONKSİYONU ---
func add_log(message: String):
	log_history.append(message)
	
	# Eğer sınır aşıldıysa en eski logu sil
	if log_history.size() > MAX_LOG_LINES:
		log_history.pop_front()
		
	# Dizideki logları aralarına satır atlaması (\n) koyarak ekrana bas
	battle_log.text = "\n".join(log_history)

func setup_initial_battlefield():
	active_player_card = CARD_SCENE.instantiate()
	player_side.add_child(active_player_card)
	
	active_enemy_card = CARD_SCENE.instantiate()
	enemy_side.add_child(active_enemy_card)
	
	player_data = CardDatabase.get_card("morn")
	active_player_card.render_data(player_data)
	current_player_hp = player_data.max_health
	
	spawn_new_enemy()
	
	add_log("[i]Ready to [color=red]FIGHT![/color][/i]")
	update_ui()

func spawn_new_enemy():
	var random_enemy_name = ENEMY_POOL[randi() % ENEMY_POOL.size()]
	enemy_data = CardDatabase.get_card(random_enemy_name)
	
	active_enemy_card.render_data(enemy_data)
	current_enemy_hp = enemy_data.max_health
	
	is_enemy_blinded = false
	
	add_log("\n[color=yellow]=== STAGE %d ===[/color]" % current_stage)
	add_log("[color=red]New enemy %s spawned![/color]" % enemy_data.card_name)

func _on_fight_button_pressed():
	fight_button.disabled = true
	start_battle_loop()

func start_battle_loop():
	add_log("Fight!")
	
	while current_player_hp > 0:
		await execute_player_turn()
		
		# --- DÜŞMAN ÖLÜMÜ & SHARD KAZANCI ---
		if current_enemy_hp <= 0:
			add_log("[color=green]Victory! %s defeated![/color]" % enemy_data.card_name)
			
			var shards_earned = 0
			match enemy_data.rarity:
				CardData.Rarity.COMMON: shards_earned = 3
				CardData.Rarity.RARE: shards_earned = 6
				CardData.Rarity.LEGENDARY: shards_earned = 15
				CardData.Rarity.MYTHIC: shards_earned = 50
			
			CurrencyManager.add_shards(shards_earned)
			add_log("[color=cyan]+%d Card Shard[/color] (Total: %d)" % [shards_earned, CurrencyManager.card_shards])
			
			current_stage += 1
			update_ui()
			await get_tree().create_timer(1.5).timeout
			
			spawn_new_enemy()
			continue
			
		await get_tree().create_timer(0.8).timeout
		
		await execute_enemy_turn()
		
		# --- OYUNCU ÖLÜMÜ & SİSTEMİ SIFIRLAMA ---
		if current_player_hp <= 0:
			add_log("\n[color=red]Defeat...[/color] Your Highscore: %d" % current_stage)
			add_log("[color=yellow]System Reset... HP restored. Back to Stage 1.[/color]")
			
			current_stage = 1
			current_player_hp = player_data.max_health
			active_player_card.update_health_ui(current_player_hp)
			update_ui()
			spawn_new_enemy()
			
			fight_button.disabled = false
			break
		
		await get_tree().create_timer(0.8).timeout

func execute_player_turn():
	add_log("[color=blue]%s[/color] attacks!" % player_data.card_name)
	
	if player_data.card_name.to_lower() == "morn":
		if randf() <= 0.15:
			is_enemy_blinded = true
			add_log("[b]PASSIVE:[/b] Enemy is [color=purple]BLINDED![/color]")
			
	current_enemy_hp -= player_data.attack_damage
	add_log("You dealt [color=orange]%d[/color] damage to the enemy!" % player_data.attack_damage)
	enemy_side.get_child(0).update_health_ui(current_enemy_hp)

func execute_enemy_turn():
	if is_enemy_blinded:
		add_log("%s MISSED!" % enemy_data.card_name)
		is_enemy_blinded = false
		return
	
	add_log("[color=red]%s[/color] is attacking!" % enemy_data.card_name)
	
	current_player_hp -= enemy_data.attack_damage
	add_log("Enemy dealt [color=orange]%d[/color] damage!" % enemy_data.attack_damage)
	player_side.get_child(0).update_health_ui(current_player_hp)

func update_ui():
	stage_info.text = "Stage: %d" % current_stage
