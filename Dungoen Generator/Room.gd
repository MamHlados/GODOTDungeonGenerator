extends Node2D

@onready var spawn_points_container = $EnemySpawns

const ENEMY_SCENE = preload("res://flying_eye.tscn")

func setup_room(type: int):
	if type == DungeonGenerator.RoomType.ENEMY:
		spawn_enemies()
		
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
