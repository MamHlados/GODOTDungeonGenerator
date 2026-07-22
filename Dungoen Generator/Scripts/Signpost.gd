extends StaticBody2D

var hint_text: String = ""
@onready var hint_label: Label = $HintLabel

func _ready() -> void:
	hint_label.modulate.a = 0.0
	hint_label.text = hint_text


func take_damage(_amount: int, _attacker_pos: Vector2) -> void:

	if hint_label.modulate.a > 0.5:
		return
		

	hint_label.text = hint_text

	var tween = create_tween()
	tween.tween_property(hint_label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(3.0)
	tween.tween_property(hint_label, "modulate:a", 0.0, 1.0)
