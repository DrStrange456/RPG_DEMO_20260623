class_name market_list_item
extends Panel


@export var nm: String
@export var qty: int
@export var typ: String

@onready var panel = $Panel
@onready var texture_rect = $Panel/TextureRect
@onready var label = $Panel/Label
@onready var txt_item_name = $Panel/txtItemName
@onready var label_2 = $Panel/Label2
@onready var txt_item_cost = $Panel/txtItemCost

func _ready():
	setName(nm)
	setQuantity(qty)
	setType(typ)


func getName() -> String:
	return txt_item_name.text
func getQuantity() -> int:
	return int(txt_item_cost.text)
func getType() -> String:
	return panel.typ

func setName(val: String):
	panel.nm = val
	txt_item_name.text = str(val)
func setQuantity(val: int):
	panel.qty = val
	txt_item_cost.text = str(val)
func setType(val: String):
	panel.typ = str(val)




# - - - - - - - - - - - - - - - - - - - - - - - - 
# - - - HANDLING CLICKS IN MARKET INVENTORY - - -
# - - - - - - - - - - - - - - - - - - - - - - - - 

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			#Item purchased
			_attempt_purchase(qty)

func _attempt_purchase(amt):
	if GameManager.PLAYER_MONEY >= abs(amt):
		if _spc_avail(nm,qty):
			GameManager.PLAYER_MONEY = int(GameManager.PLAYER_MONEY) - amt
			_add_to_inv(nm,qty)
			Events.emit_signal("refresh_market_inv_ui")
			AudioController.play_sound("sfx_buy_success")
		else:
			print("You don't have enough space in your inventory")
			AudioController.play_sound("sfx_buy_fail")
	else:
		print("You don't have enough money")
		AudioController.play_sound("sfx_buy_fail")




func _spc_avail(nam,qnty)->bool:
	return StorageManager.is_space_avail_in_inventory(nam,qnty,GameManager.PLAYER_INVENTORY_TEST)

func _add_to_inv(nam,qnty):
	StorageManager.try_add_item_to_inventory(GameManager.PLAYER_INVENTORY_TEST,nam,qnty)

# BOTTOM 
