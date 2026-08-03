extends Node

var max_health: int = 3
var current_health: int = 3
var coins: int = 0
var has_key: bool = false 
var player_dmg: int = 4
var heart_drop_chance: float = 0.10
var coin_max_drop: int = 3
var move_speed_bonus: float = 0.0
var invimcibility_bonus: float = 0.0
var knockback_bonus: float = 0.0

var time_elapsed: float = 0.0
var enemies_killed: int = 0
var total_coins_collected: int = 0


signal player_stats_changed
signal card_collected_popup(card_texture: Texture2D, description: String)

func _process(delta):
	time_elapsed += delta
	
func reset_game() -> void:
	current_health = max_health
	coins = 0
	has_key = false
	player_dmg = 4
	heart_drop_chance = 0.10
	coin_max_drop = 3
	move_speed_bonus = 0.0
	knockback_bonus = 0.0
	invimcibility_bonus = 0.0
	time_elapsed = 0.0
	enemies_killed = 0
	total_coins_collected = 0
	player_stats_changed.emit()
	
func add_coin(amount: int) -> void:
	coins += amount
	total_coins_collected += amount
	player_stats_changed.emit()
	
func gain_key() -> void:
	has_key = true
	player_stats_changed.emit()
	
func add_enemy_kill() -> void:
	enemies_killed += 1
	
func update_health(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)
	player_stats_changed.emit()
	
func apply_card_upgrade(color: String) -> void:
	match color:
		"red": heart_drop_chance += 0.05
		"yellow": coin_max_drop += 4
		"purple": player_dmg += 1
		"green": max_health += 1; current_health += 1
		"cyan": current_health = max_health
		"blue": move_speed_bonus += 50.0
		"orange": knockback_bonus += 30.0
		"pink": invimcibility_bonus += 0.3
	player_stats_changed.emit()
	print("Got card: ", color)

func card_popup(tex: Texture2D, desc: String) ->void:
	card_collected_popup.emit(tex, desc)
