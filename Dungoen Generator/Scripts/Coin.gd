extends Area2D

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
		
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player") or body.name == "Player":
		GameManager.add_coin(1)
		queue_free()
	
