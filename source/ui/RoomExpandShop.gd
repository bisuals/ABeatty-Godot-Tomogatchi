extends Control

@onready var anim_player = $AnimationPlayer
@onready var shop_container = $VBoxContainer
@onready var screen_text_label = $MaxRoomsLabel
@onready var price_label = $VBoxContainer/HBoxContainer/PriceLabel
@onready var roomManager = get_tree().get_root().get_node("MainScene/RoomManager")

var room_price: int = 10:
	set(new_value):
		price_label.text = str(new_value)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func update():
	var rooms_number = roomManager.rooms.size()
	shop_container.visible = true
	screen_text_label.visible = false
	if rooms_number == 1:
		pass
	if rooms_number == 2:
		room_price = 25
	if rooms_number >= 3:
		shop_container.visible = false
		screen_text_label.text = 'You already have max amount of rooms.'
		screen_text_label.visible = true
		
func _on_button_pressed():
	if room_price > Global.coins:
		print('Cannot afford this.')
		return
	Global.coins -= room_price
	roomManager.room_purchased()
	shop_container.visible = false
	screen_text_label.text = 'Purchased successfully!'
	screen_text_label.visible = true
