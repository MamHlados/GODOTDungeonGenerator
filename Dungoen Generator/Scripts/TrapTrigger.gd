extends Area2D

const ENEMY_SCENE: Array[PackedScene] = [
	preload("res://flying_eye.tscn"),
	preload("res://frog.tscn")
]
var chest_scene = preload("res://Chest.tscn")
var card_scene = preload("res://card_upgrade.tscn")
var reward_type: String = "none"

@onready var spawn_points: Node2D = $SpawnPoints
var is_triggered: bool = false
var enemies_alive: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.name == "Player" and not is_triggered:
		is_triggered = true
		spawn_ambush(body)

func spawn_ambush(player: Node) -> void:
	print("Its a trap")
	
	var available_markers = spawn_points.get_children()
	available_markers.shuffle()
	
	var enemy_count = randi_range(2, 3)
	enemy_count = min(enemy_count, available_markers.size())
	
	var spawned_enemies = []
	
	for i in range(enemy_count):
		var marker = available_markers[i]
		
		var random_enemy = ENEMY_SCENE.pick_random()
		var enemy = random_enemy.instantiate()
		enemy.global_position = marker.global_position
		get_tree().current_scene.call_deferred("add_child", enemy)
		
		enemies_alive += 1
		enemy.tree_exited.connect(_on_enemy_died)
		spawned_enemies.append(enemy)
		
	await get_tree().create_timer(1.0).timeout
	for enemy in spawned_enemies:
		if is_instance_valid(enemy) and enemy.has_method("wake_up"):
			enemy.wake_up(player)
func _on_enemy_died() -> void:
	enemies_alive -= 1
	
	if enemies_alive <= 0:
		room_cleared()
		
func room_cleared() -> void:
	print("You defeated them, you reward is: ", reward_type)
	
	if reward_type == "chest":
		var reward = chest_scene.instantiate()
		reward.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", reward)
		
	elif reward_type == "card":
		var card = card_scene.instantiate()
		var all_colors = ["red","yellow","purple", "green", "cyan", "blue", "orange", "pink"]
		card.card_color = all_colors.pick_random()
		card.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", card)
		
		
	queue_free()
