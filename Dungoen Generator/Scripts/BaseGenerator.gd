extends Node2D
class_name BaseGenerator

signal generation_complete

signal level_hint_generated(hint_text: String)
var current_key_pos: Vector2i = Vector2i.ZERO

@export_group("Settings")
#Grid
@export var world_size: Vector2i = Vector2i(6, 6) 
@export var number_of_rooms: int = 20
var tiles: int = 35
var tile_size:int = 16
@export var room_pixel_size: Vector2 = Vector2(tiles * tile_size, tiles * tile_size)
@onready var map_root: Node2D = %Map
@onready var void_tilemap: TileMap = %VoidDecorationsTileMap
var bg_rect: ColorRect

var current_preset: int = 0
var difficulty: int = 2
var animate_generation: bool = false

const SIGNPOST_SCENE = preload("res://signpost.tscn")

const ROOM_SCENES = {
	1:[ preload("res://ScenesRooms/From_master_roomV2/V2U.tscn"),
		preload("res://ScenesRooms/From_master_roomV3/V3U.tscn"),],
	2:[ preload("res://ScenesRooms/From_master_roomV2/V2D.tscn"),
		preload("res://ScenesRooms/From_master_roomV3/V3D.tscn"),],
	3:[ preload("res://ScenesRooms/From_master_roomV2/V2DU.tscn"),],
	4:[ preload("res://ScenesRooms/From_master_roomV2/V2R.tscn"),
		preload("res://ScenesRooms/From_master_roomV3/V3R.tscn"),],
	5:[ preload("res://ScenesRooms/From_master_roomV2/V2RU.tscn"),],
	6:[ preload("res://ScenesRooms/From_master_roomV2/V2DR.tscn"),],
	7:[ preload("res://ScenesRooms/From_master_roomV2/V2DRU.tscn"),
		preload("res://ScenesRooms/from_master_roomV4/V4DRU.tscn"),],
	8:[ preload("res://ScenesRooms/From_master_roomV2/V2L.tscn"),
		preload("res://ScenesRooms/From_master_roomV3/V3L.tscn"),],
	9:[ preload("res://ScenesRooms/From_master_roomV2/V2LU.tscn"),],
	10:[ preload("res://ScenesRooms/From_master_roomV2/V2DL.tscn"),],
	11:[ preload("res://ScenesRooms/From_master_roomV2/V2DLU.tscn"),
		 preload("res://ScenesRooms/from_master_roomV4/V4DLU.tscn"),],
	12:[ preload("res://ScenesRooms/From_master_roomV2/V2LR.tscn"),],
	13:[ preload("res://ScenesRooms/From_master_roomV2/V2LRU.tscn"),
		 preload("res://ScenesRooms/from_master_roomV4/V4LRU.tscn"),],
	14:[ preload("res://ScenesRooms/From_master_roomV2/V2DLR.tscn"),
		 preload("res://ScenesRooms/from_master_roomV4/V4DLR.tscn"),],
	15:[ preload("res://ScenesRooms/From_master_roomV2/V2DLRU.tscn"),
		 preload("res://ScenesRooms/from_master_roomV4/V4DLRU.tscn"),]
}
var flower_tiles: Array[Vector2i] = [
	Vector2i(3,9),
	Vector2i(4,9),
	Vector2i(5,9),
	Vector2i(6,9),
	Vector2i(7,9),
	Vector2i(8,9),
	Vector2i(9,9),
	Vector2i(10,9),
	Vector2i(11,9),
	Vector2i(12,9),
	Vector2i(13,9),
	Vector2i(14,9),
	Vector2i(3,10),
	Vector2i(4,10),
	Vector2i(5,10),
	Vector2i(6,10),
	Vector2i(7,10),
	Vector2i(8,10),
	Vector2i(9,10),
	Vector2i(10,10),
	Vector2i(11,10),
	Vector2i(12,10),
	Vector2i(13,10),
	Vector2i(14,10),
	Vector2i(8,11),
	Vector2i(9,11),
	Vector2i(10,11),
	Vector2i(11,11),
	Vector2i(12,11),
	Vector2i(13,11),
	Vector2i(14,11)
]
var decoration_layer: int = 0
var source_id: int = 0

enum RoomType { NORMAL, START, BOSS, LOOT, SHOP, ENEMY, BUFF, KEY, EMPTY, TRAP }

var friendly_types = [RoomType.START, RoomType.LOOT, RoomType.SHOP, RoomType.BUFF]

const TYPE_COLORS = {
	RoomType.NORMAL: Color.WHITE,
	RoomType.START: Color.GREEN,
	RoomType.BOSS: Color.DARK_RED,
	RoomType.LOOT: Color.GOLD,
	RoomType.SHOP: Color.BLUE,
	RoomType.ENEMY: Color.PURPLE,
	RoomType.BUFF: Color.CYAN,
	RoomType.KEY: Color.MAGENTA,
	RoomType.EMPTY: Color.DIM_GRAY,
	RoomType.TRAP: Color.ORANGE
}

var rooms: Array = []        
var taken_positions: Array[Vector2i] = [] 

func _ready() -> void:
	# Cap number of rooms
	var max_capacity = (world_size.x * 2) * (world_size.y * 2)
	if number_of_rooms >= max_capacity:
		number_of_rooms = int(max_capacity * 0.8)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		generate_dungeon()
		
func _get_main_direction() -> Vector2i:
	match current_preset:
		1: return Vector2i.UP
		2: return Vector2i.DOWN
		3: return Vector2i.LEFT
		4: return Vector2i.RIGHT
		_, 0, 5: return [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
		
func _get_biased_direction() -> Vector2i:
	var roll = randf()
	match current_preset:
		1: #TOWER - UP
			if roll < 0.6: return Vector2i.UP
			elif roll < 0.8: return Vector2i.LEFT
			else: return Vector2i.RIGHT
		2: #CAVE - DOWN
			if roll < 0.6: return Vector2i.DOWN
			elif roll < 0.8: return Vector2i.LEFT
			else: return Vector2i.RIGHT
		3: #SIDE - LEFT
			if roll < 0.6: return Vector2i.LEFT
			elif roll < 0.8: return Vector2i.UP
			else: return Vector2i.DOWN
		4: #SIDE - RIGHT
			if roll < 0.6: return Vector2i.RIGHT
			elif roll < 0.8: return Vector2i.UP
			else: return Vector2i.DOWN
		_, 0, 5: #BASIC and TREE
			return [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()

			
func generate_dungeon() -> void:
	print("Generating Dungeon...")
	var needed_size = int(sqrt(number_of_rooms)) + 2
	
	#PRESET - SIDES
	if current_preset == 3 or current_preset == 4:
		world_size = Vector2i(needed_size * 1.2, needed_size / 2)
	#PRESET - TOWER NEBO CAVE
	elif current_preset == 1 or current_preset == 2:
		world_size = Vector2i(needed_size / 2, needed_size * 1.2)
	elif current_preset == 5:
		world_size = Vector2i(needed_size * 1.5 , needed_size * 1.5)
	else:
		world_size = Vector2i(needed_size, needed_size)
	# 1. Setup Grid
	_initialize_grid()
	
	# 2. Create Layout
	_create_layout()
	
	# 3. Analyze Doors
	_analyze_connections() 
	
	# 4. Assign Types 
	_assign_room_types_and_gameplay() 
	
	# 5. Draw
	await _instantiate_scenes()
	
	# 6. Draw decorations
	_decorate_void()
	
	var hint = _generate_compass_hint(current_key_pos)
	
	var start_room_data = _get_room_data(Vector2i.ZERO)
	
	if start_room_data != null and start_room_data.has("instance"):
		var start_room_instance = start_room_data["instance"]
		
		var signpost = SIGNPOST_SCENE.instantiate()
		signpost.hint_text = hint
		
		signpost.position = Vector2(0, -40) 
		
		signpost.add_to_group("dungeon_cleanup")
		
		start_room_instance.add_child(signpost)
	
	generation_complete.emit()

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
	pass

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
	current_key_pos = key_pos
	
	# 4. Available spots
	var available_spots = []
		
	for pos in taken_positions:
		var room = _get_room_data(pos)
		room ["distance"] = distances.get(pos,0)
		if room["type"] == RoomType.NORMAL: 
			available_spots.append(pos)
			
	available_spots.sort_custom(func(a,b):
		return distances.get(a,0) < distances.get (b,0)
	)
	var mid_point = available_spots.size() / 2
	var early_spots = available_spots.slice(0 , mid_point)
	var late_spots = available_spots.slice(mid_point, available_spots.size())
	
	
	#Shuffle
	early_spots.shuffle()
	late_spots.shuffle()
	
	#SCALLING podle velikosti a difficulty
	var total_rooms = taken_positions.size()
	
	#Výpočet pomocí procent
	var shop_count = max(1, int(total_rooms * 0.05))
	var loot_count = max(1, int(total_rooms * (0.15 - (difficulty * 0.02))))
	var buff_count = max(1, int(total_rooms * 0.08))
	var trap_count = max(1, int(total_rooms * (0.02 + (difficulty * 0.03))))
	
	
	#Must spawns
	var late_items = []
	var early_items = []
	
	for i in range(shop_count): late_items.append(RoomType.SHOP)
	for i in range(buff_count): late_items.append(RoomType.BUFF)
	for i in range(trap_count): late_items.append(RoomType.TRAP)
	
	for i in range(loot_count): early_items.append(RoomType.LOOT)
	for i in range(buff_count - (buff_count / 2)): early_items.append(RoomType.BUFF)
	for i in range(trap_count - (trap_count / 2)): early_items.append(RoomType.TRAP)
	#5. Assign late items
	for item in late_items:
		if late_spots.size() > 0:
			var pos = _pop_safe_spot(late_spots, item)
			_get_room_data(pos)["type"] = item
		#Map too small(fat so it wont spawn late items)
		elif early_spots.size() > 0:
			var pos = _pop_safe_spot(early_spots, item)
			_get_room_data(pos)["type"] = item
		
	#6. Assign early items
	for item in early_items:
		if early_spots.size() > 0:
			var pos = _pop_safe_spot(early_spots, item)
			_get_room_data(pos)["type"] = item
		elif late_spots.size() > 0:
			var pos = _pop_safe_spot(late_spots, item)
			_get_room_data(pos)["type"] = item
	
	#Difficulty
	var remaining_spots = late_spots + early_spots
	remaining_spots.shuffle()
	var enemy_chance = float(difficulty) / 4.0
	var total_enemies = int(remaining_spots.size() * enemy_chance)
	
	var fillers = []
	for i in range(total_enemies):
		fillers.append(RoomType.ENEMY)
	while fillers.size() < remaining_spots.size():
		fillers.append(RoomType.EMPTY)
		
	fillers.shuffle()
	for i in range(remaining_spots.size()):
		var pos = remaining_spots[i]
		_get_room_data(pos)["type"] = fillers[i]
		
func _instantiate_scenes() -> void:
	for pos in taken_positions:
		var room_data = _get_room_data(pos)
		
		var mask = 0
		if room_data["door_top"]: mask += 1
		if room_data["door_bot"]: mask += 2
		if room_data["door_right"]: mask += 4
		if room_data["door_left"]: mask += 8
		
		if ROOM_SCENES.has(mask):
			var room_variation = ROOM_SCENES[mask]
			var chosen_scene = room_variation.pick_random()
			var instance = chosen_scene.instantiate()
			instance.position = Vector2(pos) * room_pixel_size
			
			room_data["instance"] = instance
			
			map_root.add_child(instance)
			
			instance.player_entered_door.connect(_on_player_transition)
			
			# THE VISUAL DEBUGGER 
			var type = room_data["type"]
			if TYPE_COLORS.has(type):
				var floor_node = instance.get_node_or_null("Floor+Walls") 
				if floor_node != null:
					floor_node.modulate = TYPE_COLORS[type]
				else:
					print("Could not find the floor node in ", instance.name)
				
			
			if instance.has_method("setup_room"):
				instance.setup_room(room_data, pos)
		if animate_generation:
			await get_tree().create_timer(0.3).timeout

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

func _has_friendly_neighbor(pos: Vector2i) -> bool:
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		var neighbor_data = _get_room_data(pos + offset)
		if neighbor_data != null:
			if neighbor_data["type"] in friendly_types:
				return true
	return false
	
func _pop_safe_spot(spots_list: Array, intended_type: RoomType) -> Vector2i:
	for i in range (spots_list.size()):
		var pos = spots_list[i]
		if not _has_friendly_neighbor(pos):
			return spots_list.pop_at(i)
	for i in range (spots_list.size()):
		var pos = spots_list[i]
		if not _has_neighbor_of_type(pos, intended_type):
			return spots_list.pop_at(i)
			
	return spots_list.pop_front()

func _has_neighbor_of_type(pos: Vector2i, type: RoomType) -> bool:
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.LEFT]:
		var neighbor_data = _get_room_data(pos + offset)
		if neighbor_data != null and neighbor_data.has("type"):
			if  neighbor_data["type"] == type:
				return true
	return false
	
func _on_player_transition	(current_pos: Vector2i, direction: Vector2i, player: CharacterBody2D):
	#Position of the next door
	var next_room_pos = current_pos + direction
	var neighbor_data = _get_room_data(next_room_pos)
	
	#Does the room exist?
	if neighbor_data != null and neighbor_data.has("instance"):
		if neighbor_data["type"] == RoomType.BOSS and not GameManager.has_key:
			print("LOCKED, YOU NEED A KEY!!!")
			player.global_position -= Vector2(direction) * 30
			return
		var next_room_node = neighbor_data["instance"]
		
		var arrival_pos = next_room_node.get_arrival_marker(direction)
		
		player.global_position = arrival_pos 
		
		var current_room_data = _get_room_data(current_pos)
		if current_room_data != null and current_room_data.has("instance"):
			if current_room_data["instance"].has_method("deactivate_room"):
				current_room_data["instance"].deactivate_room()
		if next_room_node.has_method("activate_room"):
			next_room_node.activate_room(player)
		
	
func _decorate_void() -> void:
	# VOID
	if bg_rect == null:
		bg_rect = ColorRect.new()
		bg_rect.color = Color.BLACK 
		bg_rect.size = Vector2(100000, 100000) 
		bg_rect.position = Vector2(-50000, -50000) 
		bg_rect.z_index = -100 
		add_child(bg_rect)
		
	# FLOWERS
	
	void_tilemap.clear()
	var world_pixel_bounds = world_size * tiles
	var padding = 20
	
	var min_x = -world_pixel_bounds.x - padding
	var max_x = world_pixel_bounds.x + padding
	var min_y = -world_pixel_bounds.y - padding
	var max_y = world_pixel_bounds.y + padding
	
	var total_area = (max_x - min_x) * (max_y - min_y)
	
	# Hustota kytek
	var number_of_flowers = int(total_area * 0.05) 
	
	for i in range(number_of_flowers):
		var rand_x = randi_range(min_x, max_x)
		var rand_y = randi_range(min_y, max_y)
		var tile_pos = Vector2i(rand_x, rand_y)
		
		var random_flower = flower_tiles.pick_random()
		void_tilemap.set_cell(decoration_layer, tile_pos, source_id, random_flower)
		
func _generate_compass_hint(target_pos: Vector2i) -> String:
	var dir_str = ""
	
	if target_pos.y < 0:
		dir_str += "North"
	elif target_pos.y > 0:
		dir_str += "South"
		
	if target_pos.x < 0:
		if dir_str == "": dir_str = "West"
		else: dir_str += "west"
	elif target_pos.x > 0:
		if dir_str == "": dir_str = "East"
		else: dir_str += "east"

		
	return "First you have to find key to the boss room!\nIt should be somewhere " + dir_str + "."
