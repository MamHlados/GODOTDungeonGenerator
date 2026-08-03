extends BaseEnemy

var is_chasing_player: bool = false

enum EyeState {REST, CHARGE, DASH}
var current_state = EyeState.REST
var state_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO

@export var dash_speed: float = 200.0
@export var charge_time: float = 0.8
@export var dash_time: float = 0.4
@export var rest_time: float = 1.0

@onready var sprite = $Sprite2D
func _physics_process(delta):
	if is_knocked_back:
		current_state = EyeState.REST
		state_timer = rest_time
		sprite.modulate = Color.WHITE
		super._physics_process(delta)
		return
		
	if not is_awake or not is_chasing_player or player_node == null:
		velocity = velocity.move_toward(Vector2.ZERO, dash_speed * 4 * delta)
		move_and_slide()
		return
	
	state_timer -= delta
	
	match current_state:
		
		EyeState.REST:
			velocity = velocity.move_toward(Vector2.ZERO, dash_speed * 4 * delta)
			if state_timer <= 0:
				current_state = EyeState.CHARGE
				state_timer = charge_time
				sprite.modulate = Color.RED
		EyeState.CHARGE:
			velocity = velocity.move_toward(Vector2.ZERO, dash_speed * 4 * delta)
			if state_timer <= 0:
				dash_direction = global_position.direction_to(player_node.global_position)
				current_state = EyeState.DASH
				state_timer = dash_time
				sprite.modulate = Color.WHITE
		EyeState.DASH:
			velocity = dash_direction * dash_speed
			if state_timer <= 0:
				current_state = EyeState.REST
				state_timer = rest_time
	super._physics_process(delta)


func _on_detection_zone_body_entered(body):
	if body.name == "Player":
		if not is_chasing_player:
			print("Útok")
			is_chasing_player = true
			current_state = EyeState.CHARGE
			state_timer = charge_time
			sprite.modulate = Color.RED
	
func sleep():
	super.sleep()
	is_chasing_player = false
	current_state = EyeState.REST
	sprite.modulate = Color.WHITE
	
#func _on_detection_zone_body_exited(body):
#	if body.name == "Player":
#		is_chasing_player = false


