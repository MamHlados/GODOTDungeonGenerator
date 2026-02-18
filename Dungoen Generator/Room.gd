extends Node2D

@onready var spawn_points_container = $EnemySpawns

const ENEMY_SCENE = preload("res://flying_eye.tscn")
const CHEST_SCENE = preload("res://chest.tscn")

func setup_room(type: int):
	if type == DungeonGenerator.RoomType.ENEMY:
		spawn_enemies()
		
	if type == DungeonGenerator.RoomType.LOOT:
		spawn_chest()
		
func spawn_enemies():
	#Get locations
	var available_points = spawn_points_container.get_children()
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
	if has_node("Chest"):
		var chest_marker = $Chest
		var chest = CHEST_SCENE.instantiate()
	
		chest.position = chest_marker.position
		add_child(chest)
	else:
		print("Error: MISSING CHEST IN LOOT ROOM")
