extends CharacterBody2D
class_name BaseEnemy	

var coin_scene = preload("res://coin.tscn")
var heart_scene = preload("res://heart_drop.tscn")
var card_scene = preload("res://card_upgrade.tscn")
@export var max_health: int = 10
@export var speed: int = 40

var current_health: int
var player_node: CharacterBody2D = null
var is_awake: bool = false
var is_knocked_back: bool = false
var knockback_strength: float = 350.0
var knockback_friction: float = 4.0

func _ready():
	current_health = max_health
func _physics_process(delta):
	if is_knocked_back:
		velocity = velocity.move_toward(Vector2.ZERO, knockback_strength * knockback_friction * delta)
		
	move_and_slide()
func wake_up(player: CharacterBody2D):
	print("Vstup do místnosti")
	player_node = player
	is_awake = true

func sleep():
	is_awake = false
	player_node = null
	velocity = Vector2.ZERO
	
func take_damage(amount: int, attacker_pos: Vector2):
	current_health -= amount
	
	is_knocked_back = true
	var knockback_dir = attacker_pos.direction_to(global_position)
	velocity = knockback_dir * (knockback_strength + GameManager.knockback_bonus)
	
	if current_health > 0:
		await get_tree().create_timer(0.3).timeout
		is_knocked_back = false
	if current_health <= 0:
		die()
		
func die():
	if "enemies_killed" in GameManager:
		GameManager.enemies_killed += 1
	var drop_amount = randi_range(1,GameManager.coin_max_drop)
	for i in range(drop_amount):
		var coin = coin_scene.instantiate()
		coin.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		get_tree().current_scene.call_deferred("add_child", coin)
		
	if randf() <= GameManager.heart_drop_chance:
		var heart = heart_scene.instantiate()
		heart.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
		get_tree().current_scene.call_deferred("add_child", heart)
	if randf() <= 0.05:
		var card = card_scene.instantiate()
		var all_colors = ["red","yellow","purple", "green", "cyan", "blue", "orange", "pink"]
		card.card_color = all_colors.pick_random()
		card.global_position = global_position
		get_tree().current_scene.call_deferred("add_child", card)
	queue_free()
