extends CharacterBody2D

@onready var camera = $Camera2D
@onready var anim_sprite = $AnimatedSprite2D
@onready var weapon_pivot = $WeaponPivot
@onready var sword_shape = $WeaponPivot/SwordHitBox/CollisionShape2D
@onready var slash_effect = $WeaponPivot/Effect


@export var max_health: int  = 3
@export var movement_speed = 500
@export var lunge_speed = -100

var character_direction : Vector2
var current_health: int = 3
var is_invulnarable: bool = false
var is_knocked_back: bool = false
var knockback_strenght: float = 300.0


var normal_zoom = Vector2(3, 3)
var whole_map_zoom = Vector2(0.15, 0.15)
var map_view = false

var last_facing_direction = "down"
var is_attacking: bool = false

func _physics_process(delta):
	if is_attacking:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed * 4 * delta)
		move_and_slide()
		return
	
	if is_knocked_back:
		velocity = velocity.move_toward(Vector2.ZERO, movement_speed * delta * 4)
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
	
	is_attacking = true
	var attack_dir = Vector2.ZERO
	
	match last_facing_direction:
		"right":
			weapon_pivot.rotation_degrees = 0
			attack_dir = Vector2.RIGHT
		"down":
			weapon_pivot.rotation_degrees = 90
			attack_dir = Vector2.DOWN
		"left":
			weapon_pivot.rotation_degrees = 180
			attack_dir = Vector2.LEFT
		"up":
			weapon_pivot.rotation_degrees = -90
			attack_dir = Vector2.UP
	sword_shape.disabled = false
	velocity = attack_dir * lunge_speed
	# anim_sprite.play("attack_" + last_facing_direction)
	
	slash_effect.visible = true
	var slashes = ["Slash1", "Slash2"]
	slash_effect.play(slashes.pick_random())
	
	
	# await anim_sprite.animation_finished
	await slash_effect.animation_finished
	
	sword_shape.disabled = true
	slash_effect.visible = false
	velocity = Vector2.ZERO
	
	await get_tree().create_timer(0.05).timeout
	is_attacking = false


func take_damage(amount: int, attacker_pos: Vector2):
	if is_invulnarable:
		return
	
	current_health -= amount
	print("Ahhh got hit!!! xdd")
	
	is_knocked_back = true
	var knockback_dir = attacker_pos.direction_to(global_position)
	velocity = knockback_dir * knockback_strenght
	if current_health <= 0:
		print("You died!")
	else:
		is_invulnarable = true
		await get_tree().create_timer(0.2).timeout
		is_knocked_back = false
		await get_tree().create_timer(1.0).timeout
		is_invulnarable = false


func _on_sword_hit_box_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(4, global_position)
