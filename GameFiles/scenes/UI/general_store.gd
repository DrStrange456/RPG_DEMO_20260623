extends Control


@onready var txt_money: RichTextLabel = $TabContainer/BUY/CreditsIndicator/txtMONEY
@onready var txt_money_2: RichTextLabel = $TabContainer/SELL/CreditsIndicator/txtMONEY2
@onready var market_item_sell_ui: Control = $market_item_sell_ui

@onready var player_inventory_buy = $TabContainer/BUY/PlayerInventory
@onready var player_inventory_sell = $TabContainer/SELL/PlayerInventory


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







func _ready() -> void:
	_load_merchant_wares()
	reset_sell_qty_labels()
	initialize_sell_slots()
	initialize_sell_inventory()


# - - - - - - - - - - - - - - 
# - - - HANDLING CLICKS - - -
# - - - - - - - - - - - - - - 
func slot_gui_input_sell(event: InputEvent, slot: Control):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			kbm_input_left_click(event,slot)
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			#kbm_input_right_click(event,slot)
			pass

func kbm_input_left_click(_event: InputEvent, slot: Control) -> void:
	sell_item_clicked(slot)




### - BUYING SECTION
func _load_merchant_wares():
	clear_list()
	load_merchandise()

func clear_list() -> void:
	var merch_list = $TabContainer/BUY/Merchant_Section/Panel/ScrollContainer/VBoxContainer
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
	var merch_list = $TabContainer/BUY/Merchant_Section/Panel/ScrollContainer/VBoxContainer
	var merch = load("res://scenes/objects/store/market_item.tscn").instantiate()
	var res = load(itm)
	merch.custom_minimum_size.y = 50
	merch.nm =  str(res.name)
	merch.typ =  str(res.name)
	merch.qty = qty
	merch.global_position = loc
	merch_list.add_child(merch)

func _on_tmr_update_credits_timeout() -> void:
	txt_money.text = str(GameManager.PLAYER_MONEY)



### - SELLING SECTION
func reset_sell_qty_labels():
	var sell_quantity_container = $TabContainer/SELL/SellQuantityGrid.get_children()
	for i in range(sell_quantity_container.size()):
		sell_quantity_container[i].get_child(0).text = str("0")
		sell_quantity_container[i].get_child(0).self_modulate.a = 0

func _on_tmr_update_credits_timeout2() -> void:
	txt_money_2.text = str(GameManager.PLAYER_MONEY)

func initialize_sell_slots():
	var slots_inv_sell2 = $TabContainer/SELL/SellQuantityGrid.get_children()
		# setup for keypress or click events when using slots
	for i in range(slots_inv_sell2.size()):
		if slots_inv_sell2[i].is_connected("gui_input",slot_gui_input_sell.bind(slots_inv_sell2[i])):
			slots_inv_sell2[i].gui_input.disconnect(slot_gui_input_sell.bind(slots_inv_sell2[i]))
		if slots_inv_sell2[i]:
			slots_inv_sell2[i].gui_input.connect(slot_gui_input_sell.bind(slots_inv_sell2[i]))

func sell_item_clicked(slot: Control):
	if slot:
		var slot_indx = slot.get_index()
		var sell_quantity_container = $TabContainer/SELL/SellQuantityGrid.get_children()
		# if already set for sale, reset. else, continue
		if sell_quantity_container[slot_indx].get_child(0).self_modulate.a == 1:
			#reset
			sell_quantity_container[slot_indx].get_child(0).text = "0"
			sell_quantity_container[slot_indx].get_child(0).self_modulate.a = 0
			# remove item from selling list
			for m in items_to_be_sold:
				if m.invSlotNum == slot_indx:
					items_to_be_sold.erase(m)
		else:
			# show sell quantity text
			var null_check = GameManager.PLAYER_INVENTORY_TEST[slot.get_index()][0]
			if null_check:  # continue if returns not null value
				open_sell_menu(slot)

func open_sell_menu(slot: Control):
	#open UI
	#var nm
	#var tmpPATH = GameManager.PLAYER_INVENTORY_TEST[slot.get_index()][0]
	#if tmpPATH is String:
		#nm = load(tmpPATH)
	#else:
		#nm = load(tmpPATH.resource_path)
	var nm = GameManager.PLAYER_INVENTORY_TEST[slot.get_index()][0]    # Name
	var qnty = GameManager.PLAYER_INVENTORY_TEST[slot.get_index()][1]  # Quantity
	
	if nm:
		market_item_sell_ui.visible = true
		
		var res
		if nm is String:
			res = load(nm)
		else:
			res = load(nm.resource_path)
		#var res = load(nm)
		market_item_sell_ui.set_itemName(res.name)
		market_item_sell_ui.set_slotQuantity(qnty)
		market_item_sell_ui.setup()
		market_item_sell_ui.set_slotNode(slot)
		UiManager.active_sell_ui = true

func _on_market_item_sell_ui_build_selling_block(nm, qty, slot_num):
	var sell_quantity_container = $TabContainer/SELL/SellQuantityGrid.get_children()
	
	sell_quantity_container[slot_num].get_child(0).text = str(qty)
	sell_quantity_container[slot_num].get_child(0).self_modulate.a = 1
	
	var tmpDict: Dictionary = {
		"ItemName": nm,
		"sellQty": qty,
		"invSlotNum": slot_num
	}
	
	# Dup check here
	var dupFound: bool = false
	for M in items_to_be_sold:
		if M["ItemName"] == tmpDict["ItemName"] and M["sellQty"] == tmpDict["sellQty"] and M["invSlotNum"] == tmpDict["invSlotNum"]:
			dupFound = true
	
	if !dupFound:
		items_to_be_sold.append(tmpDict)
	
	calc_selling_total2()
	#Events.emit_signal("GenStore_OnEscape_OkayToClose")

func calc_selling_total2()->void:
	var txt_sell_amount = $TabContainer/SELL/SellValueIndicator/Panel/txtSellAmount
	var tot_for_selling: int = 0
	for itm in items_to_be_sold:
		tot_for_selling += int(calc_net_gain(itm.ItemName,itm.sellQty))
	txt_sell_amount.text = str(tot_for_selling)

func calc_net_gain(item_nm,qty):
	var itm_resource = StorageManager.get_resource_by_name(item_nm)
	if item_nm == "": 
		print("unable to calc net gain - general store")
	var base_value: int = itm_resource.cost
	if base_value:
		return base_value * qty
	else:
		return 0


func _on_btn_sell_all_items_in_list_pressed():
	commence_selling()


func commence_selling():
	var txt_sell_amount = $TabContainer/SELL/SellValueIndicator/Panel/txtSellAmount
	var value_amt = 0
	for ware_item in items_to_be_sold:
		var qty_sold = ware_item.sellQty
		var qty_inv = GameManager.PLAYER_INVENTORY_TEST[ware_item.invSlotNum][1]
		if qty_sold == int(qty_inv):
			#pass
			# remove whole slot
			GameManager.PLAYER_INVENTORY_TEST[ware_item.invSlotNum][0] = null
			GameManager.PLAYER_INVENTORY_TEST[ware_item.invSlotNum][1] = 0
		else:
			## deduct qty from slot
			#1pass
			GameManager.PLAYER_INVENTORY_TEST[ware_item.invSlotNum][1] -= qty_sold
		value_amt += int(calc_net_gain(ware_item.ItemName,qty_sold))
	## update money
	GameManager.PLAYER_MONEY += value_amt
	txt_sell_amount.text = "0"
	items_to_be_sold = []
	txt_money.text = str(GameManager.PLAYER_MONEY)
	# update UI and refresh inventory
	_reset_seller_ui()
	## update buying inventory stock list
	initialize_BUY_inventory()

func _reset_seller_ui()->void:
	#Load seller stuff
	initialize_sell_slots()
	reset_sell_qty_labels()
	initialize_sell_inventory()


func initialize_sell_inventory():
	#var main_inventory: Control = $TabContainer/SELL/PlayerInventory/MainInventory
	#var main_inventory_ctrllr: GridContainer = $TabContainer/SELL/PlayerInventory/MainInventory/MainInventoryController
	
	var main_inventory_sell = player_inventory_sell.get_node("MainInventory")
	var main_inventory_sell_controller = main_inventory_sell.get_node("MainInventoryController")
	
	main_inventory_sell._refresh_inventory_items(main_inventory_sell_controller)

func initialize_BUY_inventory():
	#var main_inventory: Control = $TabContainer/BUY/PlayerInventory/MainInventory
	#var main_inventory_ctrllr: GridContainer = $TabContainer/BUY/PlayerInventory/MainInventory/MainInventoryController
	
	var main_inventory_buy = player_inventory_buy.get_node("MainInventory")
	var main_inventory_buy_controller = main_inventory_buy.get_node("MainInventoryController")
	main_inventory_buy._refresh_inventory_items(main_inventory_buy_controller)



# BOTTOM
