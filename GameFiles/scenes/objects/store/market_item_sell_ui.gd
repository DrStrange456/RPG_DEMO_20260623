extends Control

signal build_selling_block(nm,qty)

@export var item_name: String
@export var item_Slot_Qty: int

@onready var txt_item_name = $NAME/txtItemName
@onready var txt_quantity = $QUANTITY/txtQuantity
@onready var txt_sell_amount = $GAIN/txtSellAmount

@onready var slot_node: Control

var SlotClass = GameManager.glSlot

func _ready():
	txt_quantity.text = "1"
	txt_sell_amount.text = "0"
	setup()


func _input(event):
	if self.visible:
		var triggered_flag: bool = false
		if event.is_action_pressed("button_cross"):
			_on_btn_accept_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_accept"):
			_on_btn_accept_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_cancel"):
			_on_btn_cancel_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_left"):
			_on_btn_set_qty_minus_1_pressed()
			triggered_flag = true
		if event.is_action_pressed("ui_right"):
			_on_btn_set_qty_plus_1_pressed()
			triggered_flag = true
		if triggered_flag:
			get_viewport().set_input_as_handled()

func setup():
	txt_item_name.text = item_name
	txt_quantity.text = "1"
	if item_name:
		$picItemToBeSold.texture = load("res://assets/icons/" + item_name + ".png") 
		txt_sell_amount.text = str(calc_net_gain(item_name,int(txt_quantity.text)))

func set_itemName(val) -> void:
	item_name = val
func set_slotQuantity(val) -> void:
	item_Slot_Qty = int(val)
func set_slotNode(slot: Control):
	slot_node = slot
func calc_net_gain(item_nm,_qty):
	var itm_resource = StorageManager.get_resource_by_name(item_name)
	if item_nm == "": 
		print("stop here")
	var base_value: int = itm_resource.cost
	if base_value:
		return base_value * int(txt_quantity.text)
	else:
		return 0

func _on_btn_set_qty_min_pressed():
	txt_quantity.text = "1"
	txt_sell_amount.text = str(calc_net_gain(item_name,1))
func _on_btn_set_qty_minus_1_pressed():
	if int(txt_quantity.text) == 1:
		_on_btn_set_qty_max_pressed()
	else:
		if int(txt_quantity.text) > 1:
			txt_quantity.text = str(int(txt_quantity.text) - 1)
			txt_sell_amount.text = str(calc_net_gain(item_name,int(txt_quantity.text)))
func _on_btn_set_qty_plus_1_pressed():
	if int(txt_quantity.text) == item_Slot_Qty:
		_on_btn_set_qty_min_pressed()
	else:
		if int(txt_quantity.text) < item_Slot_Qty:
			txt_quantity.text = str(int(txt_quantity.text) + 1)
			txt_sell_amount.text = str(calc_net_gain(item_name,int(txt_quantity.text)))
func _on_btn_set_qty_max_pressed():
	txt_quantity.text = str(item_Slot_Qty)
	txt_sell_amount.text = str(calc_net_gain(item_name,item_Slot_Qty))
func _on_btn_cancel_pressed():
	UiManager.active_sell_ui = false
	self.visible = false
func _on_btn_accept_pressed():
	build_selling_block.emit(item_name,int(txt_quantity.text),slot_node.get_index())
	UiManager.active_sell_ui = false
	self.visible = false
