extends Node2D

@onready var ui_menu = $UI
@onready var RWbutton = $UI/Control/VBoxContainer/RANDOMWALK_BUTTON
@onready var BSPbutton = $UI/Control/VBoxContainer/BSP_BUTTON

@onready var RWgen = $RWgen
@onready var BSPgen = $BSPgen

var game_started: bool = false

func _ready() -> void:
	ui_menu.show()
	
func _on_randomwalk_button_pressed():
	_start_generation("random_walk")

func _on_bsp_button_pressed():
	_start_generation("bsp")
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("random_walk"):
		_start_generation("random_walk")
	elif event.is_action_pressed("bsp"):
		_start_generation("bsp")
			
func _start_generation(type: String) -> void:
	ui_menu.hide()
	
	RWgen._initialize_grid()
	BSPgen._initialize_grid()
	
	if type == "random_walk":
		print("Random walk generated")
		RWgen.generate_dungeon()
	elif type == "bsp":
		print("BSP generated")
		BSPgen.generate_dungeon()
	
