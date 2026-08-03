extends CanvasLayer

@onready var label_time: Label = $Control/ColorRect/Panel/VBoxContainer/LabelTime
@onready var label_kills: Label = $Control/ColorRect/Panel/VBoxContainer/LabelKills
@onready var label_coins: Label = $Control/ColorRect/Panel/VBoxContainer/LabelCoins

@onready var label_seed: Label = $Control/ColorRect/Panel/VBoxContainer/LabelSeed
@onready var label_algo: Label = $Control/ColorRect/Panel/VBoxContainer/LabelAlgo
@onready var label_rooms: Label = $Control/ColorRect/Panel/VBoxContainer/LabelRooms

@onready var next_level_button: Button = $Control/ColorRect/Panel/VBoxContainer/NextLevelButton
@onready var leave_button: Button = $Control/ColorRect/Panel/VBoxContainer/LeaveButton

func _ready() -> void:
	get_tree().paused = true
	
	var minutes = int(GameManager.time_elapsed) / 60
	var seconds = int(GameManager.time_elapsed) % 60
	label_time.text = "Completion Time: %02d:%02d" % [minutes, seconds]
	label_kills.text = "Enemies Killed: %d" % GameManager.enemies_killed
	label_coins.text = "Total Coins: %d" % GameManager.total_coins_collected
	
	label_algo.text = "Algorithm: " + str(GeneratorSettings.chosen_algorithm)
	label_rooms.text = "Number of Rooms: " + str(GeneratorSettings.num_rooms)
	label_seed.text = "Dungeon Seed: " + str(GeneratorSettings.dungeon_seed)
	
	next_level_button.pressed.connect(_on_next_level_pressed)
	leave_button.pressed.connect(_on_menu_pressed)

func _on_next_level_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().reload_current_scene()
	queue_free()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://menu.tscn")
	queue_free()
