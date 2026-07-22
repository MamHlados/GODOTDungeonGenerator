extends Area2D

@export_enum("red","yellow","purple", "green", "cyan", "blue", "orange", "pink") var card_color: String = "purple"
@onready var sprite = $Sprite2D

var descriptions = {
	"red": "+5% Chance for heart drop",
	"yellow": "+1 Max coin drop from enemies",
	"purple": "+1 Attack dmg",
	"green": "+1 Max health point",
	"cyan": "Full heal",
	"blue": "+ 50 Movement speed",
	"orange": "+ 30 Knockback",
	"pink": "0.3 Longer invincibility after being hit"
}

func _ready() -> void:
	var texture_path = "res://Assets/Cards/" + card_color + ".png"
	sprite.texture = load(texture_path)
	
	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "position", Vector2(0, -4), 0.5).as_relative().set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "position", Vector2(0, 4), 0.5).as_relative().set_trans(Tween.TRANS_SINE)

func _on_body_entered(body):
	if body.name == "Player":
		GameManager.apply_card_upgrade(card_color)
		GameManager.card_popup(sprite.texture, descriptions[card_color])
		queue_free()
