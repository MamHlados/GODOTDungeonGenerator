extends Node2D

@onready var spawn_points_enemy_container = $EnemySpawns
@onready var spawn_points_chest_container = $ChestSpawns

const ENEMY_SCENE = preload("res://flying_eye.tscn")
const CHEST_SCENE = preload("res://chest.tscn")

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
		
	if room_data["type"] == DungeonGenerator.RoomType.ENEMY:
		spawn_enemies()
		
	if room_data["type"] == DungeonGenerator.RoomType.LOOT:
		spawn_chest()
		
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
	
func spawn_enemies():
	#Get locations
	var available_points = spawn_points_enemy_container.get_children()
	
	available_points.shuffle()
	var enemy_count = randi_range(1,3)
	
	for i in range(enemy_count):
		#If no point available
		if available_points.size() == 0:
			break
		#Take the first point in the list
		var point = available_points.pop_front()
		var enemy = ENEMY_SCENE.instantiate()
		
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
