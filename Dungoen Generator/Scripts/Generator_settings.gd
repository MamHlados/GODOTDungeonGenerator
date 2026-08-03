extends Node

var chosen_algorithm: String = "RandomWalk"
var preset_id: int = 0
var difficulty_id: int = 2
var num_rooms: int = 20
var animate: bool = false
var dungeon_seed: int = 0

func prepare_seed(custom_seed_input: String) -> void:
	if custom_seed_input.strip_edges() == "" or not custom_seed_input.is_valid_int():
		randomize()
		dungeon_seed = randi_range(100000, 999999)
	else:
		dungeon_seed = custom_seed_input.to_int()
		
	seed(dungeon_seed)
