extends popup_ui

@onready var player_inventory_buy: Node2D = $PopupRoot/PlayerInventory


var items_to_be_sold: Array = []
var merchant_wares: Dictionary = {
	# Item ID : Quantity
	"res://resources/crop_carrot.tres" : 10,
	"res://resources/crop_strawberry.tres" : 10,
	"res://resources/crop_tomato.tres" : 10,
	"res://resources/crop_turnip.tres" : 10,
	"res://resources/seeds_carrot.tres" : 10,
	"res://resources/seeds_strawberry.tres" : 10,
	"res://resources/seeds_tomato.tres" : 10,
	"res://resources/seeds_turnip.tres": 10,
} 


func initialize():
	_load_merchant_wares()

func _input(_event: InputEvent) -> void:
	if visible:
		if Input.is_action_pressed("ui_cancel"):
			self.visible = false
			UiManager.active_ui = null
			UiManager.open_merchant()
			get_viewport().set_input_as_handled()  # Mark event as handled




# - - - - - - - - - - - - - - 
# - - - HANDLING CLICKS - - -
# - - - - - - - - - - - - - - 
func slot_gui_input_sell(event: InputEvent, _slot: Control):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pass






### - BUYING SECTION
func _load_merchant_wares():
	clear_list()
	load_merchandise()

func clear_list() -> void:
	var merch_list = $PopupRoot/Merchant_Section/Panel/ScrollContainer/VBoxContainer
	for m in merch_list.get_children():
		m.free()

func load_merchandise() -> void:
	var list_pos = Vector2.ZERO
	var padding_bottom: int = 54
	for n in merchant_wares:
		var nm = n                   # Name
		var cnt = merchant_wares[n]  # Quantity
		_load_merch_item(nm, cnt, list_pos)
		list_pos = Vector2(list_pos.x,list_pos.y+padding_bottom)

func _load_merch_item(itm,qty,loc: Vector2)->void:
	var merch_list = $PopupRoot/Merchant_Section/Panel/ScrollContainer/VBoxContainer
	var merch = load("res://scenes/objects/store/market_item.tscn").instantiate()
	var res = load(itm)
	merch.custom_minimum_size.y = 50
	merch.nm =  str(res.name)
	merch.typ =  str(res.name)
	merch.qty = qty
	merch.global_position = loc
	merch_list.add_child(merch)

func initialize_BUY_inventory():
	var main_inventory_buy = player_inventory_buy.get_node("MainInventory")
	var main_inventory_buy_controller = main_inventory_buy.get_node("MainInventoryController")
	main_inventory_buy._refresh_inventory_items(main_inventory_buy_controller)
