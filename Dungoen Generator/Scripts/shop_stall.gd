extends StaticBody2D

var shop_ui_scene = preload("res://shop_ui.tscn")
var is_shop_open: bool = false

var has_been_generated: bool = false
var stored_cards: Array = []
var stored_prices: Array = []
var cards_available: Array = [true, true, true]
var stored_random_price: int = 10

func take_damage(_amount: int, _attacker_pos: Vector2) -> void:
	if not is_shop_open:
		open_shop()

func open_shop():
	is_shop_open = true
	var shop = shop_ui_scene.instantiate()
	
	shop.stall_reference = self
	
	shop.shop_closed.connect(func(): is_shop_open = false)
	get_tree().current_scene.call_deferred("add_child", shop)
