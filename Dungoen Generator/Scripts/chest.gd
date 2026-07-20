extends StaticBody2D
class_name DungeonChest

@onready var hurt_box: Area2D = $HurtBox
var coin_scene = preload("res://coin.tscn")
var heart_scene = preload("res://heart_drop.tscn")
var is_opened:bool = false
	
func open_chest():
	print("Chest opened")
	is_opened = true
	var drop_amount = randi_range(8, 12)
	for i in range(drop_amount):
		var coin = coin_scene.instantiate()
		coin.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		get_tree().current_scene.call_deferred("add_child", coin)
		
	if randf() <= 0.25:
		var heart = heart_scene.instantiate()
		heart.global_position = global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		get_tree().current_scene.call_deferred("add_child", heart)
	queue_free()

func take_damage(_amount: int, _attacker_pos: Vector2) -> void:
	if not is_opened:
		open_chest()
