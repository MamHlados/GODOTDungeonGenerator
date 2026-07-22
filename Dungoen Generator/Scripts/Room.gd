extends Node2D

@onready var spawn_points_enemy_container = $EnemySpawns
@onready var spawn_points_chest_container = $ChestSpawns
@onready var spawn_points_key_container = $KeySpawns

const ENEMY_SCENE: Array[PackedScene] = [
	preload("res://flying_eye.tscn"),
	preload("res://frog.tscn")
]
const CHEST_SCENE = preload("res://chest.tscn")
const KEY_SCENE = preload("res://key.tscn")
const CARD_SCENE = preload("res://card_upgrade.tscn")
const SHOP_SCENE = preload("res://shop_stall.tscn")
const AMBUSH_SCENE = preload("res://trap_trigger.tscn")

enum RoomType { NORMAL, START, BOSS, LOOT, SHOP, ENEMY, BUFF, KEY, EMPTY, TRAP }

signal player_entered_door(current_room_pos: Vector2i, direction: Vector2i, player_node: CharacterBody2D)
var grid_pos: Vector2i

func _ready():
	#Doors representing the direction
	if has_node("DoorCollisions/LeftDoor"): $DoorCollisions/LeftDoor.body_entered.connect(_on_door_entered.bind(Vector2i.LEFT))
	if has_node("DoorCollisions/RightDoor"): $DoorCollisions/RightDoor.body_entered.connect(_on_door_entered.bind(Vector2i.RIGHT))
	if has_node("DoorCollisions/TopDoor"): $DoorCollisions/TopDoor.body_entered.connect(_on_door_entered.bind(Vector2i.UP))
	if has_node("DoorCollisions/BottomDoor"): $DoorCollisions/BottomDoor.body_entered.connect(_on_door_entered.bind(Vector2i.DOWN))
	
func setup_room(room_data: Dictionary, map_pos: Vector2i):
	grid_pos = map_pos
	
	#Turning of collisions without doors
	if not room_data["door_top"] :
		if has_node ("EnemyBlocker/TopBlocker/CollisionShape2D") and has_node("DoorCollisions/TopDoor/CollisionShape2D"):
			$DoorCollisions/TopDoor/CollisionShape2D.set_deferred("disabled", true)
			$EnemyBlocker/TopBlocker/CollisionShape2D.set_deferred("disabled", true)
	if not room_data["door_bot"]:
		if has_node ("EnemyBlocker/BottomBlocker/CollisionShape2D") and has_node("DoorCollisions/BotDoor/CollisionShape2D"):
			$DoorCollisions/BotDoor/CollisionShape2D.set_deferred("disabled", true)
			$EnemyBlocker/BottomBlocker/CollisionShape2D.set_deferred("disabled", true)
	if not room_data["door_left"]:
		if has_node ("EnemyBlocker/LeftBlocker/CollisionShape2D") and has_node("DoorCollisions/LeftDoor/CollisionShape2D"):
			$EnemyBlocker/LeftBlocker/CollisionShape2D.set_deferred("disabled", true)
			$DoorCollisions/LeftDoor/CollisionShape2D.set_deferred("disabled", true)
	if not room_data["door_right"]:
		if has_node ("EnemyBlocker/RightBlocker/CollisionShape2D") and has_node("DoorCollisions/RightDoor/CollisionShape2D"):
			$EnemyBlocker/RightBlocker/CollisionShape2D.set_deferred("disabled", true)
			$DoorCollisions/RightDoor/CollisionShape2D.set_deferred("disabled", true)
		
	if room_data["type"] == RoomType.ENEMY:
		var dist = room_data.get("distance", 0)
		spawn_enemies(dist)
		
	if room_data["type"] == RoomType.LOOT:
		spawn_chest()
	
	if room_data["type"] == RoomType.KEY:
		spawn_key()
	
	if room_data["type"] == RoomType.BUFF:
		spawn_card()
		
	if room_data["type"] == RoomType.SHOP:
		spawn_shop()
	if room_data["type"] == RoomType.TRAP:
		spawn_trap()
func _on_door_entered(body, direction: Vector2i):
	if body.name == "Player":
		player_entered_door.emit(grid_pos, direction, body)
		
func get_arrival_marker(entry_direction: Vector2i) -> Vector2:
	#The marker is oposite of the door(Teleporting from left door teleports us to the right marker)
	if entry_direction == Vector2i.UP and has_node("TeleportMarkers/BottomTP"):
		return $TeleportMarkers/BottomTP.global_position
	if entry_direction == Vector2i.DOWN and has_node("TeleportMarkers/TopTP"):
		return $TeleportMarkers/TopTP.global_position
	if entry_direction == Vector2i.LEFT and has_node("TeleportMarkers/RightTP"):
		return $TeleportMarkers/RightTP.global_position
	if entry_direction == Vector2i.RIGHT and has_node("TeleportMarkers/LeftTP"):
		return $TeleportMarkers/LeftTP.global_position
			
	return global_position
	
func spawn_enemies(distance: int):
	#Get locations
	if spawn_points_enemy_container == null:
		print("Error: In scene", self.name, " is no enemyspawner")
		return
	var available_points = spawn_points_enemy_container.get_children()
	
	available_points.shuffle()
	
	#Difficulty based on distance froms tart
	var min_enemies = 1
	var max_enemies = 1
	
	if distance >= 6:
		min_enemies = 5
		max_enemies = 7
	elif distance >= 5:
		min_enemies = 3
		max_enemies = 5
	elif distance >= 4:
		min_enemies = 3
		max_enemies = 4
	elif distance >= 2:
		min_enemies = 2
		max_enemies = 3
	else:
		min_enemies = 1
		max_enemies = 2
		
	#if more enemies then markers
	max_enemies = min(max_enemies, available_points.size())
	min_enemies = min(min_enemies, max_enemies)
	
	var enemy_count = randi_range(min_enemies,max_enemies)
	for i in range(enemy_count):
		#If no point available
		if available_points.size() == 0:
			break
		#Take the first point in the list
		var point = available_points.pop_front()
		var random_enemy = ENEMY_SCENE.pick_random()
		var enemy = random_enemy.instantiate()
		
		enemy.position = point.position
		add_child(enemy)
		
func spawn_chest():
	if spawn_points_chest_container:
		var available_points = spawn_points_chest_container.get_children()
		if available_points.size() == 0:
			print("Error: ChestSpawns container is empty!")
			return
		available_points.shuffle()
		var point = available_points.pop_front()
		var chest = CHEST_SCENE.instantiate()
	
		chest.position = point.position
		add_child(chest)
	else:
		print("Error: MISSING CHEST IN LOOT ROOM")
		
func activate_room(player: CharacterBody2D):
	for child in get_children():
		if child.has_method("wake_up"):
			child.wake_up(player)
			
func deactivate_room():
	for child in get_children():
		if child.has_method("sleep"):
			child.sleep()
			
func spawn_key():
	if spawn_points_key_container:
		var available_points = spawn_points_key_container.get_children()
		if available_points.size() == 0:
			print("Error: KeySpawns container is empty!")
			return
		available_points.shuffle()
		var point = available_points.pop_front()
		var key = KEY_SCENE.instantiate()
	
		key.position = point.position
		add_child(key)
	else:
		print("Error: MISSING KEY IN LOOT ROOM")
		
func spawn_card():
	if spawn_points_chest_container:
		var available_points = spawn_points_key_container.get_children()
		if available_points.size() == 0:
			print("Error: KeySpawns container is empty!")
			return
		available_points.shuffle()
		var point = available_points.pop_front()
		var card = CARD_SCENE.instantiate()
		var all_colors = ["red","yellow","purple", "green", "cyan", "blue", "orange", "pink"]
		card.card_color = all_colors.pick_random()
		card.position = point.position
		call_deferred("add_child", card)
	else:
		print("Erorr: MISSING CARD IN BUFF ROOM")
func spawn_shop():
	if spawn_points_chest_container:
		var available_points = spawn_points_key_container.get_children()
		if available_points.size() == 0:
			print("Error: ShopSpawn container is empty!")
			return
		available_points.shuffle()
		var point = available_points.pop_front()
		var shop = SHOP_SCENE.instantiate()
		shop.position = point.position
		call_deferred("add_child", shop)
	else:
		print("Erorr: MISSING SHOP IN SHOP ROOM")
		
func spawn_trap():
	var ambush = AMBUSH_SCENE.instantiate()
	var possible_rewards = ["chest", "card", "none"]
	ambush.reward_type = possible_rewards.pick_random()
	
	if spawn_points_chest_container and spawn_points_chest_container.get_child_count() > 0:
		var point = spawn_points_chest_container.get_child(0)
		ambush.position = point.position
	else:
		ambush.global_position = global_position
		
	add_child(ambush)
