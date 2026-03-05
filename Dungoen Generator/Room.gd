extends Node2D

@onready var spawn_points_enemy_container = $EnemySpawns
@onready var spawn_points_chest_container = $ChestSpawns

const ENEMY_SCENE = preload("res://flying_eye.tscn")
const CHEST_SCENE = preload("res://chest.tscn")

func setup_room(type: int):
	if type == DungeonGenerator.RoomType.ENEMY:
		spawn_enemies()
		
	if type == DungeonGenerator.RoomType.LOOT:
		spawn_chest()
		
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
