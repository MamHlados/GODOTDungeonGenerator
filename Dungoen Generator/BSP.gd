extends BaseGenerator
class_name BSP

@export_group("BSP Settings")
@export var min_partition_size: int = 2
@export var depth: int = 4 

func _create_layout() -> void:
	var bounds = int(ceil(sqrt(number_of_rooms * 0.6)))
	if bounds < 2: bounds = 2
	
	var dirs = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var spawn_dir = dirs.pick_random()
	
	var start_rect: Rect2i
	if spawn_dir == Vector2i.RIGHT:
		start_rect == Rect2i(1, -bounds, bounds * 2, bounds * 2)
	elif spawn_dir == Vector2i.LEFT:
		start_rect = Rect2i(-1 - bounds * 2, -bounds, bounds * 2, bounds * 2)
	elif spawn_dir == Vector2i.DOWN:
		start_rect = Rect2i(-bounds, 1, bounds * 2, bounds * 2)
	elif spawn_dir == Vector2i.UP:
		start_rect = Rect2i(-bounds, -1 - bounds * 2, bounds * 2, bounds * 2)
	
	var partitions = _split_space(start_rect, depth)
	var room_centers: Array[Vector2i] = []
	var start_pos = Vector2i.ZERO
	_set_room_data(start_pos, {"grid_pos": start_pos, "type": RoomType.START})
	taken_positions.append(start_pos)
	
	
	var new_pos = start_pos + dirs.pick_random()
	_set_room_data(new_pos,{"grid_pos": new_pos, "type": RoomType.NORMAL})
	taken_positions.append(new_pos)
	
	room_centers.append(new_pos)
	
	for p in partitions:
		var center = p.get_center()
		if abs(center.x) < world_size.x and abs(center.y) < world_size.y:
			if center != start_pos:
				room_centers.append(center)
			
	room_centers.sort_custom(func(a,b):
		var dist_a = abs(a.x) + abs(a.y)
		var dist_b = abs (b.x) + abs(b.y)
		return dist_a < dist_b
		)

	for i in range(room_centers.size() - 1):
		if taken_positions.size() >= number_of_rooms:
			print("Max limit of rooms:", taken_positions.size())
			break
		
		_create_corridor(room_centers[i], room_centers[i+1])
		
	
func _split_space(rect: Rect2i, current_depth: int) -> Array[Rect2i]:
	if current_depth == 0: return [rect]
	
	var split_horizontally = randf() > 0.5
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
	var current = start
	while current != end:
		if taken_positions.size() >= number_of_rooms:
			return
		
		if current.x != end.x:
			current.x += sign(end.x - current.x)
		elif current.y != end.y:
			current.y += sign(end.y - current.y)
		
		if _get_room_data(current) == null:
			_set_room_data(current, {"grid_pos": current, "type": RoomType.NORMAL})
			taken_positions.append(current)
