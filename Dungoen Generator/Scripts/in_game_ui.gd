extends CanvasLayer

@onready var hearth_container: HBoxContainer = $Control/MarginContainer/VBoxContainer/HearthContainer
@onready var coin_value: Label = $Control/MarginContainer/VBoxContainer/CoinContainer/CoinValue
@onready var key: TextureRect = $Control/MarginContainer/VBoxContainer/Key
@onready var card_popup = $Control/CardPopup
@onready var popup_icon = $Control/CardPopup/VBoxContainer/PopupIcon
@onready var popup_text = $Control/CardPopup/VBoxContainer/PopupText
@onready var pause_overlay: ColorRect = $Control/PauseOverlay
@onready var resume_btn: Button = $Control/PauseOverlay/VBoxContainer/ResumeButton
@onready var quit_btn: Button = $Control/PauseOverlay/VBoxContainer/QuitButton

var full_heart = preload("res://Assets/UI/HeartIconFull.png")
var empty_heart = preload("res://Assets/UI/HeartIconEmpty.png")

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameManager.player_stats_changed.connect(update_ui)
	GameManager.card_collected_popup.connect(show_card_popup_animation)
	card_popup.modulate.a =0
	update_ui()
	
	resume_btn.pressed.connect(toggle_pause)
	quit_btn.pressed.connect(quit_game)
	
	pause_overlay.visible = false
func update_ui() -> void:
	coin_value.text = str(GameManager.coins)
	
	if key != null:
		key.visible = GameManager.has_key
		
	for child in hearth_container.get_children():
		child.queue_free()
	
	for i in range(GameManager.max_health):
		var heart = TextureRect.new()
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(48, 48)
		
		if i < GameManager.current_health:
			heart.texture = full_heart
		else:
			heart.texture = empty_heart
		
		hearth_container.add_child(heart)
			
func show_card_popup_animation(tex: Texture2D, desc: String) -> void:
	get_tree().paused = true
	popup_icon.texture = tex
	popup_text.text = desc
	
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(card_popup, "modulate:a", 1.0, 0.3)
	tween.tween_interval(1.5)
	tween.tween_property(card_popup, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func(): get_tree().paused = false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	var new_pause_state = not get_tree().paused
	
	get_tree().paused = new_pause_state
	pause_overlay.visible = new_pause_state

func quit_game() -> void:
	get_tree().quit()
