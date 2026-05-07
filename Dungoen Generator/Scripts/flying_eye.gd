extends BaseEnemy

var is_chasing_player: bool = false

func _physics_process(delta):
	if is_knocked_back:
		velocity = velocity.move_toward(Vector2.ZERO, speed * 4 * delta)
		move_and_slide()
		return
		
	if is_awake and is_chasing_player and player_node !=null:
		var direction = global_position.direction_to(player_node.global_position)
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

func _on_detection_zone_body_entered(body):
	print("Jdu za tebou!!")
	if body.name == "Player":
		is_chasing_player = true

#func _on_detection_zone_body_exited(body):
#	if body.name == "Player":
#		is_chasing_player = false


func _on_hit_box_body_entered(body):
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(1, global_position)
