extends MarginContainer

const CARD_SCENE = preload("res://Scenes/card.tscn")


var player_active_effects: Array[StatusEffect] = []
var enemy_active_effects: Array[StatusEffect] = []

var player_active_on_hit_effects: Array[StatusEffect] = []


@onready var auto_fight_button: CheckButton = %AutoFightButton
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

var active_player_card : Control
var active_enemy_card : Control

const ENEMY_POOL = [
	"skeleton", "goblin", "orc", "zombie", "wolf", "witch", 
	"vampire", "slime", "ghost"
]

const BOSS_POOL = ["demon", "lich"] 

const ENEMIES_PER_STAGE = 10


var log_history: Array[String] = []
const MAX_LOG_LINES: int = 50

func _ready() -> void:

	battle_log.scroll_following = true 
	
	setup_initial_battlefield()
	fight_button.pressed.connect(_on_fight_button_pressed)

	GameManager.prestige_performed.connect(_on_prestige_performed)

func _on_prestige_performed():

	log_history.clear()
	add_log("[i][color=purple]Prestige complete! Starting anew with cosmic power...[/color][/i]")
	

	current_player_hp = player_data.max_health
	player_active_effects.clear()
	player_active_on_hit_effects.clear()
	

	update_ui()
	update_equipped_abilities_ui()
	spawn_new_enemy()
	

	fight_button.disabled = false


func add_log(message: String):
	log_history.append(message)
	

	if log_history.size() > MAX_LOG_LINES:
		log_history.pop_front()
		

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
	
	for ability_card in InventoryManager.equipped_ability_cards:

		for effect in ability_card.innate_effects:
			player_active_effects.append(effect.duplicate())
			

		for effect in ability_card.on_hit_effects:
			player_active_on_hit_effects.append(effect.duplicate())
			
	spawn_new_enemy()
	
	add_log("[i]Ready to [color=red]FIGHT![/color][/i]")
	update_ui()

	update_equipped_abilities_ui()

func spawn_new_enemy():

	var is_boss_encounter = (GameManager.current_stage % 10 == 0) and (GameManager.defeated_enemies_on_current_stage == ENEMIES_PER_STAGE - 1)
	
	var random_enemy_name = ""
	
	if is_boss_encounter:

		random_enemy_name = BOSS_POOL[randi() % BOSS_POOL.size()]
		add_log("\n[color=red]*** BOSS ENCOUNTER! ***[/color]")
	else:

		var valid_enemies: Array[String] = []
		for enemy_name in ENEMY_POOL:
			var data = CardDatabase.get_card(enemy_name)
			

			if GameManager.current_stage <= 20 and data.rarity != CardData.Rarity.COMMON:
				continue

			if GameManager.current_stage > 20 and GameManager.current_stage <= 40 and (data.rarity == CardData.Rarity.LEGENDARY or data.rarity == CardData.Rarity.MYTHIC):
				continue

			if GameManager.current_stage > 40 and GameManager.current_stage < 50 and data.rarity == CardData.Rarity.MYTHIC:
				continue
				
			valid_enemies.append(enemy_name)
		

		random_enemy_name = valid_enemies[randi() % valid_enemies.size()]

	enemy_data = CardDatabase.get_card(random_enemy_name)
	
	active_enemy_card.render_data(enemy_data)
	current_enemy_hp = enemy_data.max_health
	
	enemy_active_effects.clear()
	for effect in enemy_data.innate_effects:
		enemy_active_effects.append(effect.duplicate())
	
	add_log("\n[color=yellow]=== STAGE %d ===[/color]" % GameManager.current_stage)
	
	if is_boss_encounter:
		add_log("[color=darkred]The mighty %s blocks your path![/color]" % enemy_data.card_name)
	else:
		add_log("[color=red]Enemy %s spawned![/color]" % enemy_data.card_name)
		
	update_ui()

func _on_fight_button_pressed():
	fight_button.disabled = true
	prepare_player_for_battle()
	start_battle_loop()

func prepare_player_for_battle():

	player_active_effects.clear()
	player_active_on_hit_effects.clear()
	

	for effect in player_data.innate_effects:
		player_active_effects.append(effect.duplicate())
	for effect in player_data.on_hit_effects:
		player_active_on_hit_effects.append(effect.duplicate())
		

	for ability_card in InventoryManager.equipped_ability_cards:
		for effect in ability_card.innate_effects:
			player_active_effects.append(effect.duplicate())
		for effect in ability_card.on_hit_effects:
			player_active_on_hit_effects.append(effect.duplicate())
			

	update_equipped_abilities_ui()

func start_battle_loop():
	add_log("Fight!")
	
	while current_player_hp > 0:
		await execute_player_turn()
		

		if current_enemy_hp <= 0:
			if check_resurrection("enemy", enemy_active_effects, enemy_data.max_health):
				pass
			else:

				check_explode_on_death("enemy", enemy_active_effects)
				
				add_log("[color=green]Victory! %s defeated![/color]" % enemy_data.card_name)
				
				var shards_earned = 0
				match enemy_data.rarity:
					CardData.Rarity.COMMON: shards_earned = 9
					CardData.Rarity.RARE: shards_earned = 18
					CardData.Rarity.LEGENDARY: shards_earned = 45
					CardData.Rarity.MYTHIC: shards_earned = 150
				
				CurrencyManager.add_shards(shards_earned)
				add_log("[color=cyan]+%d Card Shard[/color] (Total: %d)" % [shards_earned, CurrencyManager.card_shards])
				

				GameManager.defeated_enemies_on_current_stage += 1
				GameManager.total_enemies_defeated += 1

				if GameManager.defeated_enemies_on_current_stage >= ENEMIES_PER_STAGE:
					GameManager.current_stage += 1
					GameManager.defeated_enemies_on_current_stage = 0
					

					if GameManager.current_stage > GameManager.highest_stage:
						GameManager.highest_stage = GameManager.current_stage
						
					add_log("[color=gold]Stage Cleared! Advancing to Stage %d[/color]" % GameManager.current_stage)



				if current_player_hp <= 0:
					if check_resurrection("player", player_active_effects, player_data.max_health):
						pass
					else:
						handle_player_defeat()
						break
						
				update_ui()
				await get_tree().create_timer(1.5).timeout
				
				spawn_new_enemy()
				continue
				
		await get_tree().create_timer(0.8).timeout
		
		await execute_enemy_turn()
		

		if current_player_hp <= 0:
			if check_resurrection("player", player_active_effects, player_data.max_health):
				pass
			else:
				handle_player_defeat()
				PopupManager.show_message("You died...", Color.DARK_RED)
				break
				
		await get_tree().create_timer(0.8).timeout

func add_effect_to_enemy(new_effect: StatusEffect):
	match new_effect.stack_behavior:

		StatusEffect.StackBehavior.INDEPENDENT:
			enemy_active_effects.append(new_effect)
			add_log("Enemy is affected by [color=yellow]%s![/color]" % new_effect.name)

		StatusEffect.StackBehavior.STACK:
			var found = false
			for existing in enemy_active_effects:
				if existing.effect_type == new_effect.effect_type:
					existing.power += new_effect.power
					existing.duration = max(existing.duration, new_effect.duration)
					add_log("📈 [color=yellow]%s[/color] stacked! Total power: %d" % [new_effect.name, existing.power])
					found = true
					break
			if not found:
				enemy_active_effects.append(new_effect)
				add_log("Enemy is affected by [color=yellow]%s![/color]" % new_effect.name)
		
		StatusEffect.StackBehavior.REFRESH:

			var found = false
			for existing in enemy_active_effects:
				if existing.name == new_effect.name:
					existing.duration = new_effect.duration
					add_log("🔄 [color=yellow]%s[/color] refreshed!" % new_effect.name)
					found = true
					break
			if not found:
				enemy_active_effects.append(new_effect)
				add_log("Enemy is affected by [color=yellow]%s![/color]" % new_effect.name)

	

func add_effect_to_player(new_effect: StatusEffect):
	match new_effect.stack_behavior:

		StatusEffect.StackBehavior.INDEPENDENT:
			player_active_effects.append(new_effect)
			add_log("Morn is affected by [color=yellow]%s![/color]" % new_effect.name)

		StatusEffect.StackBehavior.STACK:
			var found = false
			for existing in player_active_effects:
				if existing.effect_type == new_effect.effect_type:
					existing.power += new_effect.power
					existing.duration = max(existing.duration, new_effect.duration)
					add_log("📈 [color=yellow]%s[/color] stacked! Total power: %d" % [new_effect.name, existing.power])
					found = true
					break
			if not found:
				player_active_effects.append(new_effect)
				add_log("Morn is affected by [color=yellow]%s![/color]" % new_effect.name)
		
		StatusEffect.StackBehavior.REFRESH:
			var found = false
			for existing in player_active_effects:
				if existing.name == new_effect.name:
					existing.duration = new_effect.duration
					add_log("🔄 [color=yellow]%s[/color] refreshed!" % new_effect.name)
					found = true
					break
			if not found:
				player_active_effects.append(new_effect)
				add_log("Morn is affected by [color=yellow]%s![/color]" % new_effect.name)


func spawn_floating_text(amount: int, target_node: Control, is_player_hit: bool):
	var float_label = Label.new()
	float_label.text = str(amount)
	

	if is_player_hit:
		float_label.modulate = Color.RED
	else:
		float_label.modulate = Color.ORANGE
		

	float_label.add_theme_font_size_override("font_size", 32)
	float_label.add_theme_constant_override("outline_size", 4)
	float_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	

	target_node.add_child(float_label)
	float_label.position = Vector2(target_node.size.x / 2 - 20, target_node.size.y / 2)
	

	var tween = create_tween()

	tween.set_parallel(true)
	

	tween.tween_property(float_label, "position:y", float_label.position.y - 120, 0.6).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	

	tween.tween_property(float_label, "modulate:a", 0.0, 0.6).set_delay(0.2)
	

	tween.set_parallel(false)
	tween.tween_callback(float_label.queue_free)

func hit_shake(target_node: Control):
	var original_pos = target_node.position
	var tween = create_tween()
	

	tween.tween_property(target_node, "position:x", original_pos.x + 15, 0.05)
	tween.tween_property(target_node, "position:x", original_pos.x - 15, 0.05)
	tween.tween_property(target_node, "position:x", original_pos.x + 10, 0.05)
	tween.tween_property(target_node, "position:x", original_pos.x - 10, 0.05)

	tween.tween_property(target_node, "position", original_pos, 0.05)

func screen_shake(intensity: float = 20.0, duration: float = 0.3):
	var original_pos = self.position
	var tween = create_tween()
	

	tween.tween_property(self, "position", original_pos + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), duration / 4.0)
	tween.tween_property(self, "position", original_pos + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), duration / 4.0)
	tween.tween_property(self, "position", original_pos + Vector2(randf_range(-intensity/2, intensity/2), randf_range(-intensity/2, intensity/2)), duration / 4.0)
	

	tween.tween_property(self, "position", original_pos, duration / 4.0)

func execute_player_turn():
	add_log("\n[color=blue]%s[/color] attacks!" % player_data.card_name)


	var first_damage = apply_pre_attack_buffs(player_data.attack_damage, player_active_effects, enemy_active_effects) 
	var final_damage = int(round(first_damage * (1.0 + GameManager.talent_damage_modifier / 100.0)))


	var hit_data = check_blind_and_leech(player_active_effects, player_data.card_name, final_damage)
	
	if hit_data["is_hit"]:
		current_enemy_hp -= final_damage
		active_enemy_card.update_health_ui(current_enemy_hp)
		

		spawn_floating_text(final_damage, active_enemy_card, false)
		hit_shake(active_enemy_card)
		

		if final_damage > 100 or enemy_data.rarity == CardData.Rarity.MYTHIC:
			screen_shake(30.0, 0.4)
		else:
			screen_shake(10.0, 0.2)

		
		add_log("You dealt [color=orange]%d[/color] damage!" % final_damage)


		if hit_data["heal_amount"] > 0:
			current_player_hp += hit_data["heal_amount"]
			current_player_hp = clamp(current_player_hp, 0, player_data.max_health)
			active_player_card.update_health_ui(current_player_hp)
			add_log("Leech healed [color=green]%d[/color] HP!" % hit_data["heal_amount"])

		for effect in player_active_on_hit_effects:
			add_effect_to_enemy(effect.duplicate())

	await get_tree().create_timer(0.8).timeout


	current_player_hp = process_turn_end_effects(current_player_hp, player_active_effects, player_data.card_name)
	
	active_player_card.update_health_ui(current_player_hp)

func execute_enemy_turn():
	add_log("\n[color=red]%s[/color] attacks!" % enemy_data.card_name)



	var first_damage = apply_pre_attack_buffs(enemy_data.attack_damage, enemy_active_effects, player_active_effects)
	var defense_multiplier = 1.0 - (GameManager.talent_defense_modifier / 100.0)
	var final_damage = int(round(first_damage * defense_multiplier))


	var hit_data = check_blind_and_leech(enemy_active_effects, enemy_data.card_name, final_damage)
	
	if hit_data["is_hit"]:
		current_player_hp -= final_damage
		active_player_card.update_health_ui(current_player_hp)


		spawn_floating_text(final_damage, active_player_card, false)
		hit_shake(active_player_card)
		

		if final_damage > 100 or enemy_data.rarity == CardData.Rarity.MYTHIC:
			screen_shake(30.0, 0.4)
		else:
			screen_shake(10.0, 0.2)

		
		add_log("Enemy dealt [color=orange]%d[/color] damage!" % final_damage)


		if hit_data["heal_amount"] > 0:
			current_enemy_hp += hit_data["heal_amount"]
			current_enemy_hp = clamp(current_enemy_hp, 0, enemy_data.max_health)
			active_enemy_card.update_health_ui(current_enemy_hp)
			add_log("🩸 Leech healed enemy for [color=green]%d[/color] HP!" % hit_data["heal_amount"])


		for effect in enemy_data.on_hit_effects:
			add_effect_to_player(effect.duplicate())



	current_enemy_hp = process_turn_end_effects(current_enemy_hp, enemy_active_effects, enemy_data.card_name)
	active_enemy_card.update_health_ui(current_enemy_hp)

func update_ui():
	stage_info.text = "Stage: %d (%d/%d)" % [GameManager.current_stage, GameManager.defeated_enemies_on_current_stage + 1, ENEMIES_PER_STAGE]
	shard_info.text = "Card Shards: %d" % CurrencyManager.card_shards

func apply_pre_attack_buffs(base_damage: int, attacker_effects: Array, defender_effects: Array):
	var final_damage = float(base_damage)

	for effects in attacker_effects:
		if effects.effect_type == StatusEffect.Type.DAMAGE_BUFF:
			var bonus_damage = (base_damage * effects.power) / 100.0
			final_damage += bonus_damage
	for effects in defender_effects:
		if effects.effect_type == StatusEffect.Type.DEFENSE_BUFF:
			var blocked_damage = (base_damage * effects.power) / 100.0
			final_damage -= blocked_damage

	return int(round(final_damage))

func process_turn_end_effects(target_hp: int, active_effects: Array[StatusEffect], target_name: String) -> int:
	var current_hp = target_hp
	

	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		

		match effect.effect_type:
			StatusEffect.Type.BURN, StatusEffect.Type.POISON:
				current_hp -= effect.power
				add_log("%s takes [color=orange]%d[/color] %s damage!" % [target_name, effect.power, effect.name])
				

		if effect.duration < 999:
			effect.duration -= 1
		

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

func update_equipped_abilities_ui():
	var container = %EquippedAbilitiesContainer

	for child in container.get_children():
		child.queue_free()

	for ability_card in InventoryManager.equipped_ability_cards:
		var icon_rect = TextureRect.new()

		icon_rect.texture = ability_card.card_texture

		icon_rect.custom_minimum_size = Vector2(48, 48)

		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		icon_rect.tooltip_text = ability_card.card_name + "\n" + ability_card.card_description

		if ability_card.card_texture != null:
			icon_rect.texture = ability_card.card_texture
		else:


			var placeholder = PlaceholderTexture2D.new()
			placeholder.size = Vector2(48, 48)
			icon_rect.texture = placeholder
			icon_rect.modulate = Color(0.8, 0.2, 0.2)


		container.add_child(icon_rect)

func check_resurrection(target: String, active_effects: Array[StatusEffect], max_hp: int) -> bool:
	for i in range(active_effects.size() - 1, -1, -1):
		var effect = active_effects[i]
		if effect.effect_type == StatusEffect.Type.RESURRECTION:
			var heal_amount = (max_hp * effect.power) / 100
			if heal_amount <= 0: heal_amount = max_hp

			if target == "player":
				current_player_hp = heal_amount
				active_player_card.update_health_ui(current_player_hp)
				add_log("✨ [color=cyan]Morn[/color] refuses to die! RESURRECTED with [color=green]%d[/color] HP!" % heal_amount)
			else:
				current_enemy_hp = heal_amount
				active_enemy_card.update_health_ui(current_enemy_hp)
				add_log("💀 The enemy defies death! RESURRECTED with [color=green]%d[/color] HP!" % heal_amount)
			
			active_effects.remove_at(i)
			return true
	return false

func check_explode_on_death(target: String, active_effects: Array[StatusEffect]):
	for effect in active_effects:
		if effect.effect_type == StatusEffect.Type.EXPLODE_ON_DEATH:
			var explosion_damage = effect.power
			if target == "enemy":
				current_player_hp -= explosion_damage
				active_player_card.update_health_ui(current_player_hp)
				add_log("💥 The enemy explodes on death, dealing [color=orange]%d[/color] damage to you!" % explosion_damage)
			else:
				current_enemy_hp -= explosion_damage
				active_enemy_card.update_health_ui(current_enemy_hp)
				add_log("💥 You explode on death, dealing [color=orange]%d[/color] damage to the enemy!" % explosion_damage)
			break

func handle_player_defeat():
	check_explode_on_death("player", player_active_effects)
	add_log("\n[color=red]Defeat...[/color]")
	add_log("[color=yellow]Morn refuses to yield. Re-engaging from Stage %d, Enemy 1.[/color]" % GameManager.current_stage)
	

	GameManager.defeated_enemies_on_current_stage = 0
	
	current_player_hp = player_data.max_health
	active_player_card.update_health_ui(current_player_hp)
	update_ui()
	spawn_new_enemy()
	
	fight_button.disabled = false
	
	if auto_fight_button.button_pressed:
		add_log("[color=cyan]Auto-Fight is ON!\nRestarting battle in 1.5 seconds...[/color]")
		PopupManager.show_message("AutoFight enabled!", Color.CYAN)
		await get_tree().create_timer(1.5).timeout
		_on_fight_button_pressed()
		
