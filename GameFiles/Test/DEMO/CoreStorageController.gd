@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
extends GridContainer

# CoreStorageController.gd
# inventory links verified


@onready var core_inventory_controller_strg: GridContainer = $"../../../StorageInventoryCore_Demo/Panel/CoreInventoryController_Strg"
@onready var storage_container_core_demo: Control = $"../.."
@onready var strgInv = storage_container_core_demo.storage_core_data



var slotPreview = GmMgr.glSlotPrev
var holding_item

# - these are for tracking while holding the item
var holding_item_resource
var holding_item_qty

var leftover_delta: int = 0


func _process(_delta: float) -> void:
	if holding_item != null:  # Set item holding to mouse pos
		_update_mouse_holding_item_position()

func _update_mouse_holding_item_position():
	holding_item.position = get_local_mouse_position() - Vector2(20,20)




func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
		print("added gui input")
		slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			pick_all_from_slot(event,slot)  # HANDLE LEFT CLICKS
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			pick_just_one_from_slot(event,slot)  # HANDLE RIGHT CLICKS



## LEFT CLICK
func pick_all_from_slot(_event: InputEvent, slot: InvSlotUI):
	if holding_item == null:  # Holding Item with Mouse
		Left_Click_Not_Holding(slot)


## RIGHT CLICK
func pick_just_one_from_slot(_event: InputEvent, slot: InvSlotUI):
	if !strgInv._isSlot_Empty(slot):
		if holding_item != null:  # Holding Item with Mouse
			if !strgInv._isSlotItem_diff(slot, holding_item):
				if _is_holding_stack_full(): 
					return  # slot full, cannot add
				Right_Click_Holding_Same_Item(slot)
		else:
			Right_Click_Not_Holding(slot)




## - Handle Left Clicks

func Left_Click_Not_Holding(slot: InvSlotUI):
	var context = {
				"source": self,
				"container": core_inventory_controller_strg,
				"slot_index": slot.indx
			}
	move_item_to_inventory(context)
	core_inventory_controller_strg.update_UI()






## - Handle Right Clicks

func Right_Click_Not_Holding(slot: InvSlotUI):
	#if slot.slot.quantity == 1:
		#Left_Click_Not_Holding(slot)
	#else:  # slot qty > 1
		#mouse_pick_single_item_fromSlot(slot)
	pass

func Right_Click_Holding_Same_Item(slot: InvSlotUI):
	#if !InvCore._isSlot_Empty(slot):
		#if slot.slot.quantity == 1:
			## - Mouse pick single item, add to holding -
			#mouse_take_item_fromSlot_holding(slot)
		#else:
			## - Mouse pick from multiples  -
			## decrement slot stack, and increment holding stack
			#mouse_pick_item_fromSlot_holding(slot)
	pass

















### STRG to INV
func move_item_to_inventory(ctx):
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	strgInv = storage_container_core_demo.storage_core_data
	if !strgInv._isSlot_Empty_At(intSlotIndex):
		if transfer_inventory_slot_to_container(strgInv.DATA,gcGRID_STRG.get_children(),intSlotIndex):
			strgInv._remove_item_at(intSlotIndex)
		else:
			_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0









func transfer_inventory_slot_to_container(inventory: Dictionary, container: Array, slot_index: int):
	var slot_data = inventory[slot_index]
	var item_path = slot_data[0]
	var quantity = slot_data[1]

	if item_path == null:
		return

	var item = load(item_path)
	var max_stack = item.max_stack
	var remaining = int(quantity)

	# --- fill existing stacks ---
	for slot in container:

		if remaining <= 0:
			break

		if slot.slot.item == item:

			var space = max_stack - slot.slot.quantity
			if space <= 0:
				continue

			var add = min(space, remaining)

			slot.slot.set_quantity(slot.slot.quantity + add)
			remaining -= add

	# --- fill empty slots ---
	for slot in container:

		if remaining <= 0:
			break

		if slot.slot.item == null:

			var stack = min(max_stack, remaining)

			slot.slot.set_item(item)
			slot.slot.set_quantity(stack)

			remaining -= stack

	# --- update inventory dictionary ---
	if remaining == 0:
		InvCore._remove_item_at(slot_index)
	if remaining > 0:
		leftover_delta = remaining


func _return_what_didnt_fit(gcGRID_INV: GridContainer,intSlotIndex: int):
	# - - Update Data then UI
	# DATA
	InvCore._updateItem_At(intSlotIndex,leftover_delta)
	# UI
	var handle_to_source_slot = gcGRID_INV.get_child(intSlotIndex)
	if leftover_delta <= 0:
		handle_to_source_slot.slot.clear()
	else:
		handle_to_source_slot.slot.set_quantity(leftover_delta)










## - Functions
func _is_holding_stack_full()->bool:
	var itm_stack = int(holding_item.label.text)
	var itm_max_stack = int(holding_item_resource.max_stack)
	return itm_stack == itm_max_stack

func update_UI():
	var slots = get_children()
	for m in slots:
		m.update_ui()





# BOTTOM
