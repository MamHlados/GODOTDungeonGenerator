extends BaseEnemy

var is_chasing_player: bool = false

func _physics_process(delta):
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

func _on_detection_zone_body_exited(body):
	if body.name == "Player":
		is_chasing_player = false
