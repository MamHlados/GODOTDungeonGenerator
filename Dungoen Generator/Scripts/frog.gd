extends BaseEnemy
class_name FrogEnemy

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
