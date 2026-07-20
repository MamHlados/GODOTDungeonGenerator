extends Node

var max_health: int = 3
var current_health: int = 3
var coins: int = 0
var has_key: bool = false 
var current_player: CharacterBody2D = null

signal player_stats_changed

func reset_game() -> void:
	current_health = max_health
	coins = 0
	has_key = false
	player_stats_changed.emit()
	
func add_coin(amount: int) -> void:
	coins += amount
	player_stats_changed.emit()
	
func gain_key() -> void:
	has_key = true
	player_stats_changed.emit()
	
func update_health(amount: int) -> void:
	current_health = clampi(current_health + amount, 0, max_health)
	player_stats_changed.emit()
