extends MarginContainer

const CARD_SCENE = preload("res://Scenes/card.tscn")

#sahnede aktif olan kartlar ve durum etkileri
var player_active_effects: Array[StatusEffect] = []
var enemy_active_effects: Array[StatusEffect] = []

@onready var player_side: VBoxContainer = $HBoxContainer/PlayerSide
@onready var enemy_side: VBoxContainer = $HBoxContainer/EnemySide
@onready var fight_button: Button = $HBoxContainer/LogSide/FightButton
@onready var battle_log: RichTextLabel = $HBoxContainer/LogSide/BattleLog
@onready var stage_info: Label = %StageInfo
@onready var shard_info: Label = %ShardLabel

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
	
	player_active_effects.clear()
	for effect in player_data.innate_effects:
		player_active_effects.append(effect.duplicate())
	spawn_new_enemy()
	
	add_log("[i]Ready to [color=red]FIGHT![/color][/i]")
	update_ui()

func spawn_new_enemy():
	var random_enemy_name = ENEMY_POOL[randi() % ENEMY_POOL.size()]
	enemy_data = CardDatabase.get_card(random_enemy_name)
	
	active_enemy_card.render_data(enemy_data)
	current_enemy_hp = enemy_data.max_health
	
	enemy_active_effects.clear()
	for effect in enemy_data.innate_effects:
		enemy_active_effects.append(effect.duplicate())
	
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

func add_effect_to_enemy(new_effect: StatusEffect):
	# 1. Sepette bu efekt zaten var mı diye kontrol et
	for existing_effect in enemy_active_effects:
		if existing_effect.name == new_effect.name:
			# Varsa, yeni kopya ekleme! Sadece süresini (duration) baştaki haline sıfırla/yenile
			existing_effect.duration = new_effect.duration
			add_log("🔄 The duration of [color=yellow]%s[/color] on Enemy was refreshed!" % new_effect.name)
			return # Fonksiyonu burada kes, işlemi bitir
			
	# 2. Eğer sepette yoksa, yepyeni bir hastalık olarak ekle
	enemy_active_effects.append(new_effect)
	add_log("Enemy is affected by [color=yellow]%s![/color]" % new_effect.name)

func add_effect_to_player(new_effect: StatusEffect):
	# Aynı mantığı oyuncu için de kuruyoruz
	for existing_effect in player_active_effects:
		if existing_effect.name == new_effect.name:
			existing_effect.duration = new_effect.duration
			add_log("🔄 The duration of [color=yellow]%s[/color] on You was refreshed!" % new_effect.name)
			return 
			
	player_active_effects.append(new_effect)
	add_log("You are affected by [color=yellow]%s![/color]" % new_effect.name)

func execute_player_turn():
	add_log("\n[color=blue]%s[/color] attacks!" % player_data.card_name)

	# --- 1. Durak: Saldırı öncesi buff/debufflar ---
	var final_damage = apply_pre_attack_buffs(player_data.attack_damage, player_active_effects, enemy_active_effects)

	# --- 2. Durak: Blind ve Leech kontrolü ---
	var hit_data = check_blind_and_leech(player_active_effects, player_data.card_name, final_damage)
	
	if hit_data["is_hit"]:
		current_enemy_hp -= final_damage
		enemy_side.get_child(0).update_health_ui(current_enemy_hp)
		add_log("You dealt [color=orange]%d[/color] damage!" % final_damage)

		# Can çalma varsa
		if hit_data["heal_amount"] > 0:
			current_player_hp += hit_data["heal_amount"]
			current_player_hp = clamp(current_player_hp, 0, player_data.max_health)
			player_side.get_child(0).update_health_ui(current_player_hp)
			add_log("Leech healed [color=green]%d[/color] HP!" % hit_data["heal_amount"])

		for effect in player_data.on_hit_effects:
			add_effect_to_enemy(effect.duplicate())
	# --- 3. Durak: Tur sonu efektleri (SADECE OYUNCU İÇİN) ---
	current_player_hp = process_turn_end_effects(current_player_hp, player_active_effects, player_data.card_name)
	
	player_side.get_child(0).update_health_ui(current_player_hp)

func execute_enemy_turn():
	add_log("\n[color=red]%s[/color] attacks!" % enemy_data.card_name)

	# --- 1. Durak: Saldırı öncesi buff/debufflar ---
	# DİKKAT: Saldıran düşman olduğu için enemy_active_effects ilk yazılır!
	var final_damage = apply_pre_attack_buffs(enemy_data.attack_damage, enemy_active_effects, player_active_effects)

	# --- 2. Durak: Blind ve Leech kontrolü ---
	var hit_data = check_blind_and_leech(enemy_active_effects, enemy_data.card_name, final_damage)
	
	if hit_data["is_hit"]:
		current_player_hp -= final_damage
		player_side.get_child(0).update_health_ui(current_player_hp)
		add_log("Enemy dealt [color=orange]%d[/color] damage!" % final_damage)

		# Düşmanda Can çalma varsa (Vampire)
		if hit_data["heal_amount"] > 0:
			current_enemy_hp += hit_data["heal_amount"]
			current_enemy_hp = clamp(current_enemy_hp, 0, enemy_data.max_health)
			enemy_side.get_child(0).update_health_ui(current_enemy_hp)
			add_log("🩸 Leech healed enemy for [color=green]%d[/color] HP!" % hit_data["heal_amount"])

		# --- Düşman Vurursa Bize Hastalık (On-Hit) Bulaştırsın ---
		for effect in enemy_data.on_hit_effects:
			add_effect_to_player(effect.duplicate())

	# --- 3. Durak: Tur sonu efektleri (SADECE DÜŞMAN İÇİN) ---
	# İşte düşmanın ZEHİR veya YANMA hasarını tam burada yiyecek!
	current_enemy_hp = process_turn_end_effects(current_enemy_hp, enemy_active_effects, enemy_data.card_name)
	enemy_side.get_child(0).update_health_ui(current_enemy_hp)

func update_ui():
	stage_info.text = "Stage: %d" % current_stage
	shard_info.text = "Card Shards: %d" % CurrencyManager.card_shards

func apply_pre_attack_buffs(base_damage: int, attacker_effects: Array, defender_effects: Array):
	var final_damage = base_damage

	for effects in attacker_effects:
		if effects.effect_type == StatusEffect.Type.DAMAGE_BUFF:
			var bonus_damage = (base_damage * effects.power) / 100
			final_damage += bonus_damage
	for effects in defender_effects:
		if effects.effect_type == StatusEffect.Type.DEFENSE_BUFF:
			var blocked_damage = (base_damage * effects.power) / 100
			final_damage -= blocked_damage
	return final_damage

func process_turn_end_effects(target_hp: int, active_effects: Array[StatusEffect], target_name: String) -> int:
	var current_hp = target_hp
	
	# DİKKAT: Listeden eleman silerken çökmemesi için diziyi tersten (sondan başa) tarıyoruz!
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		
		# 1. Efektin özelliğini uygula (Zehir, Yanma vs.)
		match effect.effect_type:
			StatusEffect.Type.BURN, StatusEffect.Type.POISON:
				current_hp -= effect.power
				add_log("🔥 %s takes [color=orange]%d[/color] %s damage!" % [target_name, effect.power, effect.name])
				
		# 2. Efektin süresini 1 tur azalt
		if effect.duration < 999:
			effect.duration -= 1
		
		# 3. Eğer süresi bittiyse (0 veya altındaysa) onu sahneden sil
		if effect.duration <= 0:
			active_effects.remove_at(i)
			add_log("⏳ [color=gray]The effect of %s on %s has worn off.[/color]" % [effect.name, target_name])
			
	return current_hp

func check_blind_and_leech(attacker_effects: Array, attacker_name: String, base_damage: int) -> Dictionary:
	var result = {"is_hit": true, "heal_amount": 0}

	for effect in attacker_effects:
		if effect.effect_type == StatusEffect.Type.BLIND:
			if randi() %100 < effect.power:
				add_log("%s is [color=red]BLINDED[/color] and missed the attack!" % attacker_name)
				result["is_hit"] = false
				return result
		elif effect.effect_type == StatusEffect.Type.LEECH:
			result["heal_amount"] = (base_damage * effect.power) / 100 
			add_log("%s will LEECH [color=green]%d[/color] HP on hit!" % [attacker_name, result["heal_amount"]])
	return result
