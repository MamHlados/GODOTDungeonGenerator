extends CanvasLayer

@onready var hearth_container: HBoxContainer = $Control/MarginContainer/VBoxContainer/HearthContainer
@onready var coin_value: Label = $Control/MarginContainer/VBoxContainer/CoinContainer/CoinValue
@onready var key: TextureRect = $Control/MarginContainer/VBoxContainer/Key

var full_heart = preload("res://Assets/UI/HeartIconFull.png")
var empty_heart = preload("res://Assets/UI/HeartIconEmpty.png")

func _ready():
	GameManager.player_stats_changed.connect(update_ui)
	update_ui()


func update_ui() -> void:
	coin_value.text = str(GameManager.coins)
	
	if key != null:
		key.visible = GameManager.has_key
		
	for child in hearth_container.get_children():
		child.queue_free()
	
	for i in range(GameManager.max_health):
		var heart = TextureRect.new()
		heart.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if i < GameManager.current_health:
			heart.texture = full_heart
		else:
			heart.texture = empty_heart
		
		hearth_container.add_child(heart)
			
