extends Area2D

@export var heal_amount: int = 1

func _ready():
	var height = randf_range(2.0, 5.0)
	var duration = randf_range(0.3, 0.6)
	var start_dir = 1
	if randf() > 0.5:
		start_dir = -1
	
	var tween = create_tween().set_loops()
	tween.tween_property(self,"position", Vector2(0, -height* start_dir), duration) \
		.as_relative()\
		.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self,"position", Vector2(0, height* start_dir), duration) \
		.as_relative()\
		.set_trans(Tween.TRANS_SINE)
		
func _on_body_entered(body):
	if body.name == "Player":
		if GameManager.current_health < GameManager.max_health:
			print("Healed!!")
			GameManager.update_health(heal_amount)
			queue_free()
