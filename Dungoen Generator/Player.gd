extends CharacterBody2D

@onready var camera = $Camera2D
@export var movement_speed = 500
var character_direction : Vector2

var normal_zoom = Vector2(4,4)
var whole_map_zoom = Vector2(0.2,0.2)
var map_view = false

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
	
func _input(event):
	if event.is_action_pressed("toggle_map"):
		map_view = !map_view
		toggle_camera_view()
		
func toggle_camera_view():
	var tween = create_tween()
	if map_view:
		tween.tween_property(camera, "zoom", whole_map_zoom, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	else:
		tween.tween_property(camera, "zoom", normal_zoom, 0.5).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(camera, "position", Vector2.ZERO, 0.5)
