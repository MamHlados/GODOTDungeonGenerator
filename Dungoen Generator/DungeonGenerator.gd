extends Node2D
class_name DungeonGenerator

@export_group("Settings")
#Grid
@export var world_size: Vector2i = Vector2i(6, 6) 
@export var number_of_rooms: int = 20
var tiles: int = 34
var tile_size:int = 16
@export var room_pixel_size: Vector2 = Vector2(tiles * tile_size, tiles * tile_size)

@onready var map_root: Node2D = %Map
@onready var fade_screen = $TransitionLayer/ColorRect

const ROOM_SCENES = {
	1: preload("res://ScenesRooms/From_master_roomV2/V2U.tscn"),
	2: preload("res://ScenesRooms/From_master_roomV2/V2D.tscn"),
	3: preload("res://ScenesRooms/From_master_roomV2/V2DU.tscn"),
	4: preload("res://ScenesRooms/From_master_roomV2/V2R.tscn"),
	5: preload("res://ScenesRooms/From_master_roomV2/V2RU.tscn"),
	6: preload("res://ScenesRooms/From_master_roomV2/V2DR.tscn"),
	7: preload("res://ScenesRooms/From_master_roomV2/V2DRU.tscn"),
	8: preload("res://ScenesRooms/From_master_roomV2/V2L.tscn"),
	9: preload("res://ScenesRooms/From_master_roomV2/V2LU.tscn"),
	10: preload("res://ScenesRooms/From_master_roomV2/V2DL.tscn"),
	11: preload("res://ScenesRooms/From_master_roomV2/V2DLU.tscn"),
	12: preload("res://ScenesRooms/From_master_roomV2/V2LR.tscn"),
	13: preload("res://ScenesRooms/From_master_roomV2/V2LRU.tscn"),
	14: preload("res://ScenesRooms/From_master_roomV2/V2DLR.tscn"),
	15: preload("res://ScenesRooms/From_master_roomV2/V2DLRU.tscn")
}

enum RoomType { NORMAL, START, BOSS, LOOT, SHOP, ENEMY, BUFF, KEY, EMPTY }

const TYPE_COLORS = {
	RoomType.NORMAL: Color.WHITE,
	RoomType.START: Color.GREEN,
	RoomType.BOSS: Color.DARK_RED,
	RoomType.LOOT: Color.GOLD,
	RoomType.SHOP: Color.BLUE,
	RoomType.ENEMY: Color.PURPLE,
	RoomType.BUFF: Color.CYAN,
	RoomType.KEY: Color.MAGENTA,
	RoomType.EMPTY: Color.DIM_GRAY
}

var rooms: Array = []        
var taken_positions: Array[Vector2i] = [] 

func _ready() -> void:
	# Cap number of rooms
	var max_capacity = (world_size.x * 2) * (world_size.y * 2)
	if number_of_rooms >= max_capacity:
		number_of_rooms = int(max_capacity * 0.8)
	
	generate_dungeon()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		generate_dungeon()

func generate_dungeon() -> void:
	print("Generating Dungeon...")
	
	# 1. Setup Grid
	_initialize_grid()
	
	# 2. Create Layout
	_create_layout()
	
	# 3. Analyze Doors
	_analyze_connections() 
	
	# 4. Assign Types 
	_assign_room_types_and_gameplay() 
	
	# 5. Draw
	_instantiate_scenes()

func _initialize_grid() -> void:
	rooms.clear()
	taken_positions.clear()
	
	for child in map_root.get_children():
		child.queue_free()

	for x in range(world_size.x * 2):
		var column = []
		for y in range(world_size.y * 2):
			column.append(null)
		rooms.append(column)

func _create_layout() -> void:
	var start_pos = Vector2i.ZERO
	_set_room_data(start_pos, {"grid_pos": start_pos, "type": RoomType.START})
	taken_positions.append(start_pos)
	
	_spawn_forced_neighbor(start_pos)
	
	var current_rooms = taken_positions.size()
	var safety_counter = 0
	
	while current_rooms < number_of_rooms and safety_counter < 1000:
		var new_pos = _find_valid_new_position()
		
		if new_pos != Vector2i(999, 999): 
			_set_room_data(new_pos, {"grid_pos": new_pos, "type": RoomType.NORMAL})
			taken_positions.append(new_pos)
			current_rooms += 1
		
		safety_counter += 1

func _spawn_forced_neighbor(start_pos: Vector2i) -> void:
	var dirs = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var new_pos = start_pos + dirs.pick_random()
	
	_set_room_data(new_pos, {"grid_pos": new_pos, "type": RoomType.NORMAL})
	taken_positions.append(new_pos)

func _find_valid_new_position() -> Vector2i:
	for i in range(50):
		var index = randi_range(1, taken_positions.size() - 1)
		var base_pos = taken_positions[index]
		var checking_pos = base_pos + [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()

		if _is_pos_valid(checking_pos):
			return checking_pos
	return Vector2i(999, 999)

func _is_pos_valid(pos: Vector2i) -> bool:
	if abs(pos.x) >= world_size.x or abs(pos.y) >= world_size.y: return false
	if _get_room_data(pos) != null: return false
	# Start Room Protection
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if pos + offset == Vector2i.ZERO: return false
	return true

func _analyze_connections() -> void:
	for pos in taken_positions:
		var room = _get_room_data(pos)
		room["door_top"] = _get_room_data(pos + Vector2i.UP) != null
		room["door_bot"] = _get_room_data(pos + Vector2i.DOWN) != null
		room["door_left"] = _get_room_data(pos + Vector2i.LEFT) != null
		room["door_right"] = _get_room_data(pos + Vector2i.RIGHT) != null

func _assign_room_types_and_gameplay() -> void:
	# 1. Calculate Flood Fill Distances
	var distances = _calculate_distances_from_start()
	
	# 2. Find Boss Room (Furthest Dead End)
	var boss_pos = _find_furthest_dead_end(distances)
	_get_room_data(boss_pos)["type"] = RoomType.BOSS
	
	# 3. Find Key Room (Far from Boss)
	var key_pos = _find_key_position(boss_pos, distances)
	_get_room_data(key_pos)["type"] = RoomType.KEY
	
	# 4. Available spots
	var early_spots = []
	var late_spots = []
	
	for pos in taken_positions:
		var room = _get_room_data(pos)
		if room["type"] != RoomType.NORMAL: continue
		
		var dist = distances.get(pos, 0)
		if dist <= 4:
			early_spots.append(pos)
		else:
			late_spots.append(pos)
	
	#Shuffle
	early_spots.shuffle()
	late_spots.shuffle()
	
	#Must spawns
	var late_items = [RoomType.SHOP, RoomType.BUFF, RoomType.EMPTY, RoomType.LOOT]
	var early_items = [RoomType.LOOT, RoomType.LOOT, RoomType.EMPTY, RoomType.EMPTY, RoomType.BUFF]
	
	#5. Assign late items
	for item in late_items:
		if late_spots.size() > 0:
			var pos = late_spots.pop_front()
			_get_room_data(pos)["type"] = item
		#Map too small(fat so it wont spawn late items)
		elif early_spots.size() > 0:
			var pos = early_spots.pop_front()
			_get_room_data(pos)["type"] = item
		
	#6. Assign early items
	for item in early_items:
		if early_spots.size() > 0:
			var pos = early_spots.pop_front()
			_get_room_data(pos)["type"] = item
		elif late_spots.size() > 0:
			var pos = late_spots.pop_front()
			_get_room_data(pos)["type"] = item
	
	#7. Fill the rest with Enemies room
	for pos in late_spots:
		_get_room_data(pos)["type"] = RoomType.ENEMY
	for pos in early_spots:
		_get_room_data(pos)["type"] = RoomType.ENEMY

func _instantiate_scenes() -> void:
	for pos in taken_positions:
		var room_data = _get_room_data(pos)
		
		var mask = 0
		if room_data["door_top"]: mask += 1
		if room_data["door_bot"]: mask += 2
		if room_data["door_right"]: mask += 4
		if room_data["door_left"]: mask += 8
		
		if ROOM_SCENES.has(mask):
			var instance = ROOM_SCENES[mask].instantiate()
			instance.position = Vector2(pos) * room_pixel_size
			
			room_data["instance"] = instance
			
			map_root.add_child(instance)
			
			instance.player_entered_door.connect(_on_player_transition)
			
			# THE VISUAL DEBUGGER 
			var type = room_data["type"]
			if TYPE_COLORS.has(type):
				instance.modulate = TYPE_COLORS[type]
				
			
			if instance.has_method("setup_room"):
				instance.setup_room(room_data, pos)

func _calculate_distances_from_start() -> Dictionary:
	var start_pos = Vector2i.ZERO
	var dists = {start_pos: 0}
	var queue = [start_pos]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbor = current + offset
			# If neighbor exists and we haven't visited it yet
			if _get_room_data(neighbor) != null and not dists.has(neighbor):
				dists[neighbor] = dists[current] + 1
				queue.append(neighbor)
	return dists

func _find_furthest_dead_end(distances: Dictionary) -> Vector2i:
	var max_dist = -1
	var best_pos = Vector2i.ZERO
	
	for pos in taken_positions:
		if pos == Vector2i.ZERO: continue
		if _count_neighbors(pos) == 1: # Dead end
			var d = distances.get(pos, 0)
			if d > max_dist:
				max_dist = d
				best_pos = pos
	
	# Fallback
	if best_pos == Vector2i.ZERO: best_pos = taken_positions.back()
	return best_pos

func _find_key_position(boss_pos: Vector2i, distances: Dictionary) -> Vector2i:
	var best_pos = Vector2i.ZERO
	var max_dist_from_boss = -1
	
	var fallback_pos = Vector2i.ZERO
	var max_fallback_dist = -1
	
	for pos in taken_positions:
		if pos == Vector2i.ZERO or pos == boss_pos: continue
		
		var dist_to_boss = abs(pos.x - boss_pos.x) + abs(pos.y - boss_pos.y)
		var dist_from_start = distances.get(pos, 0)
		#Furtherest room from boss
		if dist_to_boss > max_fallback_dist:
			max_fallback_dist = dist_to_boss
			fallback_pos = pos
		#Furtherest room that is atleast 3 steps from start
		if dist_from_start > 3 and dist_to_boss > max_dist_from_boss:
			max_dist_from_boss = dist_to_boss
			best_pos = pos
	#Pick the right one
	if best_pos != Vector2i.ZERO:
		return best_pos
	else:
		return fallback_pos

func _get_room_data(pos: Vector2i):
	var ax = pos.x + world_size.x
	var ay = pos.y + world_size.y
	if ax < 0 or ax >= rooms.size() or ay < 0 or ay >= rooms[0].size(): return null
	return rooms[ax][ay]

func _set_room_data(pos: Vector2i, data: Dictionary) -> void:
	rooms[pos.x + world_size.x][pos.y + world_size.y] = data

func _count_neighbors(pos: Vector2i) -> int:
	var count = 0
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if _get_room_data(pos + offset) != null: count += 1
	return count

func _on_player_transition	(current_pos: Vector2i, direction: Vector2i, player: CharacterBody2D):
	#Position of the next door
	var next_room_pos = current_pos + direction
	var neighbor_data = _get_room_data(next_room_pos)
	
	#Does the room exist?
	if neighbor_data != null and neighbor_data.has("instance"):
		var next_room_node = neighbor_data["instance"]
		
		var arrival_pos = next_room_node.get_arrival_marker(direction)
		
		#player wont move when the screen is fading
		player.set_physics_process(false)
		
		#transition fading
		var tween_out = create_tween()
		tween_out.tween_property(fade_screen, "modulate:a", 1.0, 1.5)
		await tween_out.finished
		
		player.global_position = arrival_pos 
		
		#back to transparent screen
		var tween_in = create_tween()
		tween_in.tween_property(fade_screen, "modulate:a", 0.0, 0.3)
		await tween_in.finished
		
		#player can move now
		player.set_physics_process(true)
	
