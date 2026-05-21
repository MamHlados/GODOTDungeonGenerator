extends BaseGenerator
class_name BSP

@export_group("BSP Settings")
@export var min_partition_size: int = 2
@export var depth: int = 4 

func _create_layout() -> void:
	var bounds = int(ceil(sqrt(number_of_rooms * 0.8)))
	if bounds < 2: bounds = 2
	
	var dirs = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var spawn_dir = _get_main_direction()
	
	var start_rect: Rect2i
	
	var max_x = world_size.x - 1
	var max_y = world_size.y - 1
	
	var size_x = min(bounds * 2, max_x)
	var size_y = min(bounds * 2, max_y)
	
	if spawn_dir == Vector2i.RIGHT:
		start_rect = Rect2i(1, -size_y / 2, size_x, size_y)
	elif spawn_dir == Vector2i.LEFT:
		start_rect = Rect2i(-size_x, -size_y / 2, size_x, size_y)
	elif spawn_dir == Vector2i.DOWN:
		start_rect = Rect2i(-size_x / 2, 1, size_x, size_y)
	elif spawn_dir == Vector2i.UP:
		start_rect = Rect2i(-size_x / 2, -size_y, size_x, size_y)
		
	
	var partitions = _split_space(start_rect, depth)
	var room_centers: Array[Vector2i] = []
	var start_pos = Vector2i.ZERO
	_set_room_data(start_pos, {"grid_pos": start_pos, "type": RoomType.START})
	taken_positions.append(start_pos)
	
	var forced_neighbor = start_pos + spawn_dir
	_set_room_data(forced_neighbor, {"grid_pos": forced_neighbor, "type": RoomType.NORMAL})
	taken_positions.append(forced_neighbor)
	
	for p in partitions:
		var center = p.get_center()
		if abs(center.x) < world_size.x and abs(center.y) < world_size.y:
			if center != start_pos and center != forced_neighbor:
				room_centers.append(center)
	if current_preset == 5:
		room_centers.shuffle()
	else:
		room_centers.sort_custom(func(a,b):
			var dist_a = abs(a.x - forced_neighbor.x) + abs(a.y - forced_neighbor.y)
			var dist_b = abs(b.x - forced_neighbor.x) + abs(b.y - forced_neighbor.y)
			return dist_a < dist_b
	)
	
	for i in range(room_centers.size() ):
		if taken_positions.size() >= number_of_rooms:
			break
		if current_preset == 5:
			var target = _find_closest_taken_pos(room_centers[i])
			_create_corridor(room_centers[i], target)
		else:
			if i < room_centers.size() - 1:
				_create_corridor(room_centers[i], room_centers[i+1])
		
	var fallback_loops = 0
	while taken_positions.size() < number_of_rooms and fallback_loops < 2000:
		fallback_loops += 1
		
		var random_existing_room = taken_positions.pick_random()
		
		if random_existing_room == Vector2i.ZERO: continue
		var step_dir = _get_biased_direction()
		var pad_pos = random_existing_room + step_dir
		
		var is_next_to_start = (abs(pad_pos.x) + abs(pad_pos.y) == 1)
		if is_next_to_start and pad_pos != forced_neighbor: continue
		
		if pad_pos != Vector2i.ZERO and _get_room_data(pad_pos) == null:
			if abs(pad_pos.x) < world_size.x and abs(pad_pos.y) < world_size.y:
				_set_room_data(pad_pos, {"grid_pos": pad_pos, "type": RoomType.NORMAL})
				taken_positions.append(pad_pos)
				
func _split_space(rect: Rect2i, current_depth: int) -> Array[Rect2i]:
	if current_depth == 0: return [rect]
	
	var split_horizontally = _get_biased_direction()
	if rect.size.x > rect.size.y * 1.5: split_horizontally = false
	elif rect.size.y > rect.size.x * 1.5: split_horizontally = true
	
	var max_split = (rect.size.y if split_horizontally else rect.size.x) - min_partition_size
	if max_split <= min_partition_size: return [rect]
	
	var split_point = randi_range(min_partition_size, max_split)
	var rect1: Rect2i
	var rect2: Rect2i
	
	if split_horizontally:
		rect1 = Rect2i(rect.position, Vector2i(rect.size.x, split_point))
		rect2 = Rect2i(rect.position + Vector2i(0, split_point), Vector2i(rect.size.x, rect.size.y - split_point))
	else:
		rect1 = Rect2i(rect.position, Vector2i(split_point, rect.size.y))
		rect2 = Rect2i(rect.position + Vector2i(split_point, 0), Vector2i(rect.size.x - split_point, rect.size.y))
	
	var result: Array[Rect2i] = []
	result.append_array(_split_space(rect1, current_depth - 1))
	result.append_array(_split_space(rect2, current_depth - 1))
	return result
	
func _create_corridor(start: Vector2i, end: Vector2i) -> void:
	if _get_room_data(start) == null:
		_set_room_data(start, {"grid_pos": start, "type": RoomType.NORMAL})
		taken_positions.append(start)
	var current = start
	while current != end:
		if taken_positions.size() >= number_of_rooms:
			return
		
		var next_step = current
		if next_step.x != end.x:
			next_step.x += sign(end.x - current.x)
		elif next_step.y != end.y:
			next_step.y += sign(end.y - current.y)
			
		if next_step == Vector2i.ZERO:
			if current.y != end.y: current.y += sign(end.y - current.y)
			else: current.x += sign(end.x - current.x)
			continue 
			
		current = next_step
		
		if current_preset == 5 and _get_room_data(current) != null:
			return
		if _get_room_data(current) == null:
			_set_room_data(current, {"grid_pos": current, "type": RoomType.NORMAL})
			taken_positions.append(current)

func _should_split_horizontally() -> bool:
	var roll = randf()
	match current_preset:
		1, 2: #TOWER - UP, CAVE - DOWN
			return roll < 0.75
		3, 4: # SIDE - LEFT, SIDE - RIGHT
			return roll < 0.25 
		_, 0: #BASIC
			return roll < 0.5
		
func _find_closest_taken_pos(pos: Vector2i) -> Vector2i:
	var closest = taken_positions[0]
	var min_dist = 1000
	for taken in taken_positions:
		var d = abs(pos.x - taken.x) +abs(pos.y - taken.y)
		if d < min_dist:
			min_dist = d
			closest = taken
	return closest
