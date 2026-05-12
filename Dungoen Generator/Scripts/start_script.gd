extends Node2D

@onready var RWgen = $RWgen
@onready var BSPgen = $BSPgen

var game_started: bool = false

func _ready() -> void:
	if GeneratorSettings.dungeon_seed != "":
		seed(GeneratorSettings.dungeon_seed.hash())
		print("Vlastní seed: ", GeneratorSettings.dungeon_seed)
	else:
		randomize()
		print("Nahodny seed")
	
	var activate_generator = null
	if GeneratorSettings.chosen_algorithm == "RandomWalk":
		activate_generator = RWgen
		BSPgen.queue_free()
	else:
		activate_generator = BSPgen
		RWgen.queue_free()
		
	activate_generator.number_of_rooms = GeneratorSettings.num_rooms
	#activate_generator.current_preset = GeneratorSettings.preset_id
	#activate_generator.animate_generation = GeneratorSettings.animate
	#activate_generator.difficulty = GeneratorSettings.difficulty_id
	
	
	print("GENERACE MAPY")
	print("Algoritmus: ", GeneratorSettings.chosen_algorithm)
	activate_generator.generate_dungeon()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://menu.tscn")

	
