extends BaseGenerator
class_name RandomWalk

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
