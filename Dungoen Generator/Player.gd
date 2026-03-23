extends CharacterBody2D

@onready var camera = $Camera2D
@onready var anim_sprite = $AnimatedSprite2D

@export var movement_speed = 500
var character_direction : Vector2

var normal_zoom = Vector2(4, 4)
var whole_map_zoom = Vector2(0.2, 0.2)
var map_view = false

var last_facing_direction = "down"
var is_attacking = false

func _physics_process(delta):
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	character_direction.x = Input.get_axis("move_left","move_right")
	character_direction.y = Input.get_axis("move_up","move_down")
	character_direction = character_direction.normalized()
	
	if character_direction:
		velocity = character_direction * movement_speed
		
		# Figure out which way we are looking based on movement
		if character_direction.x > 0:
			last_facing_direction = "right"
			anim_sprite.flip_h = false # Look right
		elif character_direction.x < 0:
			last_facing_direction = "left"
			anim_sprite.flip_h = true  # Look left
		elif character_direction.y > 0:
			last_facing_direction = "down"
			anim_sprite.flip_h = false
		elif character_direction.y < 0:
			last_facing_direction = "up"
			anim_sprite.flip_h = false
			
	else:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed)

	update_animation()
	
	move_and_slide()
	
func _input(event):
	# Camera Toggle
	if event.is_action_pressed("toggle_map"):
		map_view = !map_view
		toggle_camera_view()
		
	if event.is_action_pressed("attack") and not is_attacking:
		perform_attack()
		
func toggle_camera_view():
	var tween = create_tween()
	if map_view:
		tween.tween_property(camera, "zoom", whole_map_zoom, 0.5).set_trans(Tween.TRANS_CUBIC)
	else:
		tween.tween_property(camera, "zoom", normal_zoom, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(camera, "position", Vector2.ZERO, 0.5)



func update_animation():
	if is_attacking:
		return # Don't interrupt the attack animation
		
	if velocity.length() > 0:
		# Player is moving
		if last_facing_direction in ["left", "right"]:
			anim_sprite.play("walk_side")
		elif last_facing_direction == "down":
			anim_sprite.play("walk_down")
		elif last_facing_direction == "up":
			anim_sprite.play("walk_up")
	else:
		# Player is standing still
		anim_sprite.play("idle")

func perform_attack():
	
	# is_attacking = true
	# anim_sprite.play("attack_" + last_facing_direction)
	# await anim_sprite.animation_finished
	# is_attacking = false
	pass
