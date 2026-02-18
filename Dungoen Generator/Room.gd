extends Node2D
class_name Room

# -- TEXTURES --
@export var spU: Texture2D
@export var spD: Texture2D
@export var spR: Texture2D
@export var spL: Texture2D
@export var spUD: Texture2D
@export var spRL: Texture2D
@export var spUR: Texture2D
@export var spUL: Texture2D
@export var spDR: Texture2D
@export var spDL: Texture2D
@export var spULD: Texture2D
@export var spRUL: Texture2D
@export var spDRU: Texture2D
@export var spLDR: Texture2D
@export var spUDRL: Texture2D

# -- PROPERTIES --
var grid_pos: Vector2
var type: int # 0 = Normal, 1 = Start, 2 = Boss

# Boolean properties for doors
var door_top: bool
var door_bot: bool
var door_left: bool
var door_right: bool

# -- COLORS --
@export var normal_color: Color = Color.CORNSILK
@export var enter_color: Color = Color.CHARTREUSE
@export var boss_color: Color = Color.CRIMSON 

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	pick_sprite()
	pick_color()

func pick_sprite():
	#Top=1, Bot=2, Right=4, Left=8
	var mask = 0
	if door_top: mask += 1
	if door_bot: mask += 2
	if door_right: mask += 4
	if door_left: mask += 8
	
	match mask:
		0: sprite.texture = null
		1: sprite.texture = spU
		2: sprite.texture = spD
		3: sprite.texture = spUD
		4: sprite.texture = spR
		5: sprite.texture = spUR
		6: sprite.texture = spDR
		7: sprite.texture = spDRU
		8: sprite.texture = spL
		9: sprite.texture = spUL
		10: sprite.texture = spDL
		11: sprite.texture = spULD
		12: sprite.texture = spRL
		13: sprite.texture = spRUL
		14: sprite.texture = spLDR
		15: sprite.texture = spUDRL

func pick_color():
	if type == 0:
		sprite.modulate = normal_color
	elif type == 1:
		sprite.modulate = enter_color
	elif type == 2:
		sprite.modulate = boss_color
