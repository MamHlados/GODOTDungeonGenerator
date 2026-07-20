extends Area2D

@export var speed: float = 250.0
@export var damage: int = 1

var direction: Vector2 = Vector2.ZERO:
	set(new_dir):
		direction = new_dir
		rotation = direction.angle()

@onready var anim_player = $AnimationPlayer


func _ready():
	anim_player.play("shoot")

func _physics_process(delta):
	global_position += direction * speed * delta


func _on_body_entered(body):
	if body is TileMap:
		print("Střela narazila do zdi")
		queue_free()


func _on_area_entered(area):
	var hit_target = area.get_parent()
	
	if hit_target.has_method("take_damage"):
		print("ZÁSAH")
		hit_target.take_damage(damage, global_position - direction * 100.0)
		queue_free()

