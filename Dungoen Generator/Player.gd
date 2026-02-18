extends CharacterBody2D

@export var movement_speed = 500
var character_direction : Vector2

func _physics_process(delta):
	character_direction.x = Input.get_axis("move_left","move_right")
	character_direction.y = Input.get_axis("move_up","move_down")
	character_direction = character_direction.normalized()
	
	if character_direction.x > 0: $AnimatedSprite2D.flip_h = false
	elif character_direction.x < 0: $AnimatedSprite2D.flip_h = true
	
	if character_direction:
		velocity = character_direction * movement_speed
		#if $AnimatedSprite2D.animation != "walking" : $AnimatedSprite2D.animation = "walking"
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)
		if $AnimatedSprite2D.animation != "idle": $AnimatedSprite2D.animation = "idle"
	
	move_and_slide()
	
