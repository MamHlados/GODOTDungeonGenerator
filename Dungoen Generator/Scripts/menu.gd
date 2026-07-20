extends Control

@onready var preset_option = $UI/PanelContainer/MarginContainer/VBoxContainer/Type
@onready var difficulty_option = $UI/PanelContainer/MarginContainer/VBoxContainer/Difficulty
@onready var generate_button = $UI/PanelContainer/MarginContainer/Generate
@onready var exit_button = $UI/PanelContainer/MarginContainer/Exit
@onready var random_walk_button = $UI/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/RanWalk
@onready var bsp_button = $UI/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BSP
@onready var animate_button = $UI/PanelContainer/MarginContainer/VBoxContainer/ShowAnimButton
@onready var num_rooms_box = $UI/PanelContainer/MarginContainer/VBoxContainer/NumRooms
@onready var seed_input = $UI/PanelContainer/MarginContainer/VBoxContainer/Seed



func _ready():
	preset_option.add_item("Basic", 0)
	preset_option.add_item("Tower (UP)", 1)
	preset_option.add_item("Cave (DOWN)", 2)
	preset_option.add_item("Side (LEFT)", 3)
	preset_option.add_item("Side (RIGHT)", 4)
	preset_option.add_item("Tree", 5)
	
	preset_option.select(0)
	
	difficulty_option.add_item("Friendly", 0)
	difficulty_option.add_item("Easy", 1)
	difficulty_option.add_item("Normal", 2)
	difficulty_option.add_item("Hard", 3)
	difficulty_option.add_item("Death", 4)
	
	difficulty_option.select(2)
	
	random_walk_button.button_pressed = true



func _on_generate_pressed():
	print("Startuji GENERATOR")
	
	GameManager.reset_game()
	
	var chosen_algo = "RandomWalk"
	if bsp_button.button_pressed:
		chosen_algo = "BSP"
	
	GeneratorSettings.chosen_algorithm = chosen_algo
	GeneratorSettings.preset_id = preset_option.get_selected_id()
	GeneratorSettings.difficulty_id = difficulty_option.get_selected_id()
	GeneratorSettings.num_rooms = num_rooms_box.value
	GeneratorSettings.animate = animate_button.button_pressed
	GeneratorSettings.dungeon_seed = seed_input.text
	
	get_tree().change_scene_to_file("res://dungeon_generator.tscn")


func _on_exit_pressed():
	print("Vypínám hru")
	get_tree().quit()
