extends Node2D
class_name DungeonGenerator

# --- CONFIGURATION ---
@export_group("Settings")
@export var world_size: Vector2i = Vector2i(6, 6) # Larger grid for better pathing
@export var number_of_rooms: int = 20
@export var room_pixel_size: Vector2 = Vector2(256, 256)

@export_group("References")
@onready var map_root: Node2D = %Map

# --- SCENES ---
const ROOM_SCENES = {
	1: preload("res://ScenesRooms/U.tscn"),
	2: preload("res://ScenesRooms/D.tscn"),
	3: preload("res://ScenesRooms/DU.tscn"),
	4: preload("res://ScenesRooms/R.tscn"),
	5: preload("res://ScenesRooms/RU.tscn"),
	6: preload("res://ScenesRooms/DR.tscn"),
	7: preload("res://ScenesRooms/DRU.tscn"),
	8: preload("res://ScenesRooms/L.tscn"),
	9: preload("res://ScenesRooms/LU.tscn"),
	10: preload("res://ScenesRooms/DL.tscn"),
	11: preload("res://ScenesRooms/DLU.tscn"),
	12: preload("res://ScenesRooms/LR.tscn"),
	13: preload("res://ScenesRooms/LRU.tscn"),
	14: preload("res://ScenesRooms/DLR.tscn"),
	15: preload("res://ScenesRooms/DLRU.tscn")
}

# --- ROOM LOGIC (NEW) ---
enum RoomType { NORMAL, START, BOSS, LOOT, SHOP, ENEMY, TRAP, BUFF, KEY, EMPTY }

const TYPE_COLORS = {
	RoomType.NORMAL: Color.WHITE,
	RoomType.START: Color.GREEN,
	RoomType.BOSS: Color.DARK_RED,
	RoomType.LOOT: Color.GOLD,
	RoomType.SHOP: Color.BLUE,
	RoomType.ENEMY: Color.PURPLE,
	RoomType.TRAP: Color.ORANGE,
	RoomType.BUFF: Color.CYAN,
	RoomType.KEY: Color.MAGENTA,
	RoomType.EMPTY: Color.DIM_GRAY
}

# --- STATE VARIABLES ---
var rooms: Array = []        
var taken_positions: Array[Vector2i] = [] 

# --- MAIN LOOP ---

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
	
	# 4. Assign Types (The New Logic)
	_assign_room_types_and_gameplay() 
	
	# 5. Draw
	_instantiate_scenes()

# --- STEP 1 & 2: LAYOUT GENERATION ---

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

# --- STEP 3: CONNECTIONS ---

func _analyze_connections() -> void:
	for pos in taken_positions:
		var room = _get_room_data(pos)
		room["door_top"] = _get_room_data(pos + Vector2i.UP) != null
		room["door_bot"] = _get_room_data(pos + Vector2i.DOWN) != null
		room["door_left"] = _get_room_data(pos + Vector2i.LEFT) != null
		room["door_right"] = _get_room_data(pos + Vector2i.RIGHT) != null

# --- STEP 4: GAMEPLAY LOGIC (TYPES) ---

func _assign_room_types_and_gameplay() -> void:
	# 1. Calculate Flood Fill Distances
	var distances = _calculate_distances_from_start()
	
	# 2. Find Boss Room (Furthest Dead End)
	var boss_pos = _find_furthest_dead_end(distances)
	_get_room_data(boss_pos)["type"] = RoomType.BOSS
	
	# 3. Find Key Room (Far from Boss)
	var key_pos = _find_key_position(boss_pos, distances)
	_get_room_data(key_pos)["type"] = RoomType.KEY
	
	# 4. Prepare Logic Bags
	var early_bag = [RoomType.LOOT, RoomType.LOOT, RoomType.EMPTY, RoomType.EMPTY]
	for i in range(5): early_bag.append(RoomType.ENEMY)
	
	var late_bag = [RoomType.SHOP, RoomType.BUFF, RoomType.TRAP, RoomType.TRAP]
	for i in range(8): late_bag.append(RoomType.ENEMY)
	
	early_bag.shuffle()
	late_bag.shuffle()
	
	# 5. Assign Remaining Rooms
	for pos in taken_positions:
		var room = _get_room_data(pos)
		# Skip if already assigned (Start, Boss, Key)
		if room["type"] != RoomType.NORMAL: continue
		
		var dist = distances.get(pos, 0)
		var new_type = RoomType.ENEMY
		
		# Logic: Dist < 4 is "Early Game", Dist > 4 is "Late Game"
		if dist <= 4:
			if early_bag.size() > 0: new_type = early_bag.pop_front()
		else:
			if late_bag.size() > 0: new_type = late_bag.pop_front()
			
		room["type"] = new_type

# --- STEP 5: DRAWING ---

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
			
			# --- THE VISUAL DEBUGGER ---
			var type = room_data["type"]
			if TYPE_COLORS.has(type):
				instance.modulate = TYPE_COLORS[type]
				
			map_root.add_child(instance)

# --- UTILITIES ---

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
	
	for pos in taken_positions:
		if pos == Vector2i.ZERO or pos == boss_pos: continue
		if _count_neighbors(pos) == 1: # Dead End
			# Distance logic: Keep away from Boss
			var dist = abs(pos.x - boss_pos.x) + abs(pos.y - boss_pos.y)
			if dist > max_dist_from_boss:
				max_dist_from_boss = dist
				best_pos = pos
				
	if best_pos == Vector2i.ZERO: best_pos = taken_positions.pick_random()
	return best_pos

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
