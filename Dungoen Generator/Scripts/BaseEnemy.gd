extends CharacterBody2D
class_name BaseEnemy	

@export var max_health: int = 10
@export var speed: int = 40
@export var detection_radius: float = 120

var current_health: int
var player_node: CharacterBody2D = null
var is_awake: bool = false

func _ready():
	current_health = max_health

func wake_up(player: CharacterBody2D):
	print("Vstup do místnosti")
	player_node = player
	is_awake = true

func sleep():
	is_awake = false
	
func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()
		
func die():
	queue_free()
