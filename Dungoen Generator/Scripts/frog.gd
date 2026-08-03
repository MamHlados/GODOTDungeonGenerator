extends BaseEnemy
class_name FrogEnemy

enum FrogState {REST, CHARGE}
var current_state = FrogState.REST
var state_timer: float = 0.0

@export var charge_time: float = randf_range(0.5, 0.6) 
@export var rest_time: float = randf_range(1.5, 2.0)

@export var spit_scene: PackedScene = preload("res://waterspit.tscn")
var is_player_in_range: bool = false

@onready var sprite_2d = $Sprite2D

@export var frog_color_variant: int = -1:
	set(new_variant):
		frog_color_variant = new_variant
		if sprite_2d:
			sprite_2d.frame_coords.y = frog_color_variant

func _ready() -> void:
	super._ready()
	if frog_color_variant == -1:
		frog_color_variant = randi_range(0, 7) 
	else:
		sprite_2d.frame_coords.y = frog_color_variant
	
	state_timer = rest_time

func _physics_process(delta):
	super._physics_process(delta)

	if is_knocked_back:
		current_state = FrogState.REST
		state_timer = rest_time
		sprite_2d.modulate = Color.WHITE
		return

	if is_awake and player_node != null:
		if is_player_in_range or current_state == FrogState.CHARGE:
			state_timer -= delta
			
			match current_state:
				FrogState.REST:
					if state_timer <= 0:
						current_state = FrogState.CHARGE
						state_timer = charge_time
						sprite_2d.modulate = Color.RED
						
				FrogState.CHARGE:
					if state_timer <= 0:
						spit_water()
						current_state = FrogState.REST
						state_timer = rest_time
						sprite_2d.modulate = Color.WHITE
		else:
			current_state = FrogState.REST
			sprite_2d.modulate = Color.WHITE

func spit_water():
	if spit_scene == null: return
	
	var spit = spit_scene.instantiate()
	get_parent().add_child(spit)
	spit.global_position = global_position

	var dir_to_player = global_position.direction_to(player_node.global_position)
	spit.direction = dir_to_player

func _on_attack_range_body_entered(body):
	if body.name == "Player":
		is_player_in_range = true
		
func sleep():
	super.sleep()
	is_player_in_range = false
	current_state = FrogState.REST
	sprite_2d.modulate = Color.WHITE
	
