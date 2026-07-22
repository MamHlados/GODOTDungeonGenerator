extends CanvasLayer

signal shop_closed

var reroll_price: int = 5

var all_colors = ["red", "yellow", "purple", "green", "cyan", "blue", "orange", "pink"]
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

var current_shop_cards = []

var stall_reference: Node = null

@onready var coin_label: Label = $ShopPanelContainer/MarginContainer/MainVBox/Header/CoinLabel

@onready var icon1: TextureRect = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card1/Icon1
@onready var desc1: Label = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card1/Desc1
@onready var buy_btn1: Button = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card1/BuyButton1
@onready var card1_box: VBoxContainer = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card1

@onready var icon2: TextureRect = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card2/Icon2
@onready var desc2: Label = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card2/Desc2
@onready var buy_btn2: Button = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card2/BuyButton2
@onready var card2_box: VBoxContainer = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card2

@onready var icon3: TextureRect = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card3/Icon3
@onready var desc3: Label = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card3/Desc3
@onready var buy_btn3: Button = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card3/BuyButton3
@onready var card3_box: VBoxContainer = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/CardsBox/Card3

@onready var random_btn: Button = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/Actions/RandomButton
@onready var random_result_label: Label = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/Actions/RandomResultLabel
@onready var reroll_btn: Button = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/Actions/RerollButton
@onready var close_btn: Button = $ShopPanelContainer/MarginContainer/MainVBox/CardContent/Actions/CloseButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	if random_result_label:
		random_result_label.modulate.a = 0.0
	buy_btn1.pressed.connect(func(): buy_card(0))
	buy_btn2.pressed.connect(func(): buy_card(1))
	buy_btn3.pressed.connect(func(): buy_card(2))
	reroll_btn.pressed.connect(reroll_shop)
	random_btn.pressed.connect(buy_random_card)
	close_btn.pressed.connect(close_shop)
	
	if stall_reference != null and stall_reference.has_been_generated:
		load_shop_state()
	else:
		generate_shop_cards()
		
func generate_shop_cards() -> void:
	
	stall_reference.stored_cards.clear()
	stall_reference.stored_prices.clear()
	stall_reference.cards_available = [true, true, true]
	
	for i in range(3):
		stall_reference.stored_cards.append(all_colors.pick_random())
		
		stall_reference.stored_prices.append(randi_range(15, 20)) 
		
		
	stall_reference.stored_random_price = randi_range(10, 15)
	
	stall_reference.has_been_generated = true
	load_shop_state()
	
func load_shop_state() -> void:
	card1_box.visible = stall_reference.cards_available[0]
	card2_box.visible = stall_reference.cards_available[1]
	card3_box.visible = stall_reference.cards_available[2]
	
	icon1.texture = load("res://Assets/Cards/" + stall_reference.stored_cards[0] + ".png")
	icon2.texture = load("res://Assets/Cards/" + stall_reference.stored_cards[1] + ".png")
	icon3.texture = load("res://Assets/Cards/" + stall_reference.stored_cards[2] + ".png")
	
	desc1.text = descriptions[stall_reference.stored_cards[0]]
	desc2.text = descriptions[stall_reference.stored_cards[1]]
	desc3.text = descriptions[stall_reference.stored_cards[2]]
	
	buy_btn1.text = "Buy: " + str(stall_reference.stored_prices[0])
	buy_btn2.text = "Buy " + str(stall_reference.stored_prices[1])
	buy_btn3.text = "Buy " + str(stall_reference.stored_prices[2])
	random_btn.text = "Random Card: " + str(stall_reference.stored_random_price)
	reroll_btn.text = "Reroll: " + str(reroll_price)
	
	update_ui()
	
func update_ui() -> void:
	coin_label.text = "Coins: " + str(GameManager.coins)
	
	buy_btn1.disabled = GameManager.coins < stall_reference.stored_prices[0]
	buy_btn2.disabled = GameManager.coins < stall_reference.stored_prices[1]
	buy_btn3.disabled = GameManager.coins < stall_reference.stored_prices[2]
	reroll_btn.disabled = GameManager.coins < reroll_price
	random_btn.disabled = GameManager.coins < stall_reference.stored_random_price
	
func buy_card(index: int) -> void:
	var price = stall_reference.stored_prices[index]
	if GameManager.coins >= price:
		GameManager.coins -= price
		var color = stall_reference.stored_cards[index]
		GameManager.apply_card_upgrade(color)
		
		stall_reference.cards_available[index] = false 
		
		if index == 0: card1_box.visible = false
		elif index == 1: card2_box.visible = false
		elif index == 2: card3_box.visible = false
		
		update_ui()
		
func reroll_shop() -> void:
	if GameManager.coins >= reroll_price:
		GameManager.coins -= reroll_price
		generate_shop_cards()
		
func buy_random_card() -> void:
	var price = stall_reference.stored_random_price
	if GameManager.coins >= price:
		GameManager.coins -= price
		var blind_card = all_colors.pick_random()
		GameManager.apply_card_upgrade(blind_card)
		
		stall_reference.stored_random_price = randi_range(10, 15)
		random_btn.text = "Random: " + str(stall_reference.stored_random_price)
		random_result_label.text = "Získáno:\n" + descriptions[blind_card]
		
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(random_result_label, "modulate:a", 1.0, 0.2)
		tween.tween_interval(2.0)
		tween.tween_property(random_result_label, "modulate:a", 0.0, 0.5)
		
		update_ui()

func close_shop() -> void:
	get_tree().paused = false
	shop_closed.emit()
	queue_free()
