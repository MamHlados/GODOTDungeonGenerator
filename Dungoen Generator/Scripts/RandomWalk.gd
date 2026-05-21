extends BaseGenerator
class_name RandomWalk

func _create_layout() -> void:
	if current_preset == 5:
		_create_tree_layout()
		return
		
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

func _create_tree_layout() -> void:
	var start_pos = Vector2i.ZERO
	_set_room_data(start_pos, {"grid_pos": start_pos, "type": RoomType.START})
	taken_positions.append(start_pos)
	
	var initial_dir = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT].pick_random()
	
	var branches = []
	branches.append({"pos": start_pos, "dir": initial_dir, "length": randi_range(2, 4)})
	
	var current_rooms = 1
	var safety_counter = 0
	
	while current_rooms < number_of_rooms and branches.size() > 0 and safety_counter < 1000:
		safety_counter += 1
		var branch = branches.pop_front()
		var current_pos = branch.pos
		var current_dir = branch.dir 
		var length = branch.length
		
		for step in range(length):
			var next_pos = current_pos + current_dir
			
			if _is_pos_valid(next_pos):
				_set_room_data(next_pos, {"grid_pos": next_pos, "type": RoomType.NORMAL})
				taken_positions.append(next_pos)
				current_rooms += 1
				current_pos = next_pos
				
				if current_rooms >= number_of_rooms: 
					break
			else:
				break
				
		if current_rooms >= number_of_rooms:
			break
		
		var split_count = randi_range(1, 3) 
		
		var forward = current_dir
		var left = Vector2i(-current_dir.y, current_dir.x)
		var right = Vector2i(current_dir.y, -current_dir.x)
		
		var possible_dirs = [forward, left, left, right, right]
		possible_dirs.shuffle()
		
		for i in range(split_count):
			var new_dir = possible_dirs[i]
			var new_length = randi_range(2, 4) 
			
			branches.append({
				"pos": current_pos,
				"dir": new_dir,
				"length": new_length
			})
	

func _spawn_forced_neighbor(start_pos: Vector2i) -> void:
	var new_pos = start_pos + _get_biased_direction()
	
	_set_room_data(new_pos, {"grid_pos": new_pos, "type": RoomType.NORMAL})
	taken_positions.append(new_pos)

func _find_valid_new_position() -> Vector2i:
	for i in range(50):
		var index = 0
		if randf() < 0.6:
			index = taken_positions.size() - 1
		else:
			index = randi_range(1, taken_positions.size() - 1)
		var base_pos = taken_positions[index]
		var checking_pos = base_pos + _get_biased_direction()
		
		if _is_pos_valid(checking_pos):
			return checking_pos
	return Vector2i(999, 999)

func _is_pos_valid(pos: Vector2i) -> bool:
	if abs(pos.x) >= world_size.x or abs(pos.y) >= world_size.y: return false
	if _get_room_data(pos) != null: return false
	if current_preset == 5: return true
	# Start Room Protection
	for offset in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if pos + offset == Vector2i.ZERO: return false
	return true
