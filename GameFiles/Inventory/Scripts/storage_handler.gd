class_name storage_click_event_manager
extends Node


@onready var ptrINVENTORY = GameManager.PLAYER_INVENTORY_TEST # For Debugging
var ITEM_REGISTRY: Dictionary = {}
var leftover_delta: int = 0

var DEBUG_COLLECT := false



func _ready() -> void:
	var items = load_resources_from_folder("res://resources/")
	for item in items:
		register_resource(item)
	
	#print("Storage Manager ready at: ", Time.get_ticks_msec())
	#var carrot = load("res://resources/crop_carrot.tres")
	#var tomato = load("res://resources/crop_tomato.tres")
	#var strawberry = load("res://resources/crop_strawberry.tres")
	#var turnip = load("res://resources/crop_turnip.tres")
	#var seeds_carrot = load("res://resources/seeds_carrot.tres")
	#var seeds_strawberry = load("res://resources/seeds_strawberry.tres")
	#var seeds_tomato = load("res://resources/seeds_tomato.tres")
	#var seeds_turnip = load("res://resources/seeds_turnip.tres")
	#
	#ITEM_REGISTRY[carrot.name] = carrot
	#ITEM_REGISTRY[tomato.name] = tomato
	#ITEM_REGISTRY[strawberry.name] = strawberry
	#ITEM_REGISTRY[turnip.name] = turnip
	#ITEM_REGISTRY[seeds_carrot.name] = seeds_carrot
	#ITEM_REGISTRY[seeds_strawberry.name] = seeds_strawberry
	#ITEM_REGISTRY[seeds_tomato.name] = seeds_tomato
	#ITEM_REGISTRY[seeds_turnip.name] = seeds_turnip




func register_resource(res_item: Resource):
	if res_item:
		ITEM_REGISTRY[res_item.name] = res_item
	else:
		print_debug("Invalid Resource")


### INV to STRG
func move_item_to_storage(ctx):
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	if ptrINVENTORY[intSlotIndex][0] != null:
		if transfer_inventory_slot_to_container(ptrINVENTORY,gcGRID_STRG.get_children(),intSlotIndex):
			_remove_from_inventory(gcGRID_INV,intSlotIndex)  # All items successfully transferred
		else:
			_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0

func move_single_item_to_storage(ctx):
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	
	ptrINVENTORY = GameManager.PLAYER_INVENTORY_TEST
	if ptrINVENTORY[intSlotIndex][0] != null:
		if int(ptrINVENTORY[intSlotIndex][1]) == 1:
			# only 1 left in slot
			var context = {
				"source": gcGRID_INV,
				"container": gcGRID_STRG,
				"slot_index": intSlotIndex
			}
			move_item_to_storage(context)
		else:
			# more than 1 in slot, just move 1 and update count
			handle_click_InvToStrg_OnlyOne(gcGRID_INV,gcGRID_STRG,intSlotIndex)

### STRG to INV
func move_item_to_inventory(ctx):
	var SRC = ctx.slot_clicked
	var gcGRID_INV = ctx.source
	var gcGRID_STRG = ctx.container
	var intSlotIndex = ctx.slot_index
	if SRC.slot.item != null:
		if _transfer_storage_to_inv(SRC,gcGRID_INV,intSlotIndex):
			_remove_from_storage(gcGRID_STRG,intSlotIndex)
		else:
			_return_what_didnt_fit_strg(SRC,gcGRID_STRG,intSlotIndex)
		leftover_delta = 0

func move_single_item_to_inventory(ctx):
	var SRC = ctx.slot_clicked
	var gcGRID_INV = ctx.container
	var gcGRID_STRG = ctx.source
	var intSlotIndex = ctx.slot_index
	if SRC.slot.item != null:
		handle_click_StrgToInv_single_item(SRC,gcGRID_INV,gcGRID_STRG,intSlotIndex)





func handle_click_InvToStrg_OnlyOne(gcGRID_INV: GridContainer,gcGRID_STRG: GridContainer, intSlotIndex: int):
	if ptrINVENTORY[intSlotIndex][0] != null:
		_transfer_inv_to_storage_JustOne(gcGRID_STRG,intSlotIndex)
		_return_what_didnt_fit(gcGRID_INV,intSlotIndex)
		leftover_delta = 0

func handle_click_StrgToInv_single_item(SRC: InvSlotUI,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.slot.item != null:
		var amount = int(SRC.qty_label.text)
		if amount == 1:
			# only 1 left in slot
			_transfer_storage_to_inv(SRC,gcGRID_INV,intSlotIndex)
			if leftover_delta == 0:
				_remove_from_storage(gcGRID_STRG,intSlotIndex)
		else:
			# more than 1 in slot, just move 1 and update count
			handle_click_StrgToInv_OnlyOne(SRC,gcGRID_STRG,gcGRID_INV,intSlotIndex)
	else:
		print("nothing to move")




### SUPPORT FUNCTIONS
func _remove_from_inventory(gcGRID: GridContainer, intSlotIndex: int):
	# - - Remove from Data then remove from UI
	# DATA
	ptrINVENTORY[intSlotIndex][0] = null
	ptrINVENTORY[intSlotIndex][1] = 0
	# UI
	var slots = gcGRID.get_children()
	slots[intSlotIndex]._update(null,0)

func _transfer_inv_to_storage(gcGRID_DEST: GridContainer,slotIndex: int):
	var item = load(ptrINVENTORY[slotIndex][0])
	var amount = ptrINVENTORY[slotIndex][1]
	var remaining:int  = int(amount)
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	for slot in slots:
		if slot.itm == item and int(slot.slot.quantity) < item.max_stack:
			var space = item.max_stack - int(slot.label.text)
			var to_add = min(space, remaining)
			slot.label.text = str(int(slot.label.text) + to_add)
			slot.slot.quantity = int(slot.label.text)
			slot._refresh()
			remaining -= to_add
			if remaining <= 0:
				return true  # Done adding
	# Step 2: Fill new empty slots
	for slot in slots:
		if slot.itm == null:
			var to_add = min(item.max_stack, remaining)
			slot.itm = item
			slot.label.text = str(int(slot.label.text) + to_add)
			slot.slot.quantity = int(slot.label.text)
			slot._refresh()
			remaining -= to_add
			if remaining <= 0:
				return true  # Done adding
	## Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func _return_what_didnt_fit(gcGRID_INV: GridContainer,intSlotIndex: int):
	# - - Update Data then UI
	# DATA
	ptrINVENTORY[intSlotIndex][1] = leftover_delta
	# UI
	var handle_to_source_slot = gcGRID_INV.get_child(intSlotIndex)
	if leftover_delta <= 0:
		handle_to_source_slot.slot.clear()
	else:
		handle_to_source_slot.slot.set_quantity(leftover_delta)

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
		ptrINVENTORY[slot_index][0] = null
	if remaining > 0:
		leftover_delta = remaining

func _transfer_storage_to_inv(SRC: InvSlotUI,gcGRID_DEST: GridContainer,_slotIndex: int):
	var item = SRC.slot.item
	var amount = int(SRC.qty_label.text)
	var remaining = amount
	var destIndex: int = 0
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	destIndex = 0
	for slot in slots:
		if slot.slot.item == item and int(slot.qty_label.text) < item.max_stack:
			var space = int(item.max_stack) - int(ptrINVENTORY[destIndex][1])
			var to_add = min(space, remaining)
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = new_qty
			slot.update_ui()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			if remaining <= 0:
				return true  # Done adding
		destIndex += 1
	# Step 2: Fill new empty slots
	destIndex = 0
	for slot in slots:
		if slot.slot.item == null:
			var to_add = min(item.max_stack, remaining)
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.slot.item = item
			slot.qty_label.text = new_qty
			slot.slot.quantity = new_qty
			slot.update_ui()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			if remaining <= 0:
				return true  # Done adding
		destIndex += 1
	# Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func _remove_from_storage(gcGRID: GridContainer, intSlotIndex: int):
	# - - Only remove from UI.  Not handling data same as inventory.
	# UI
	var slots = gcGRID.get_children()
	slots[intSlotIndex].slot.clear()

func _return_what_didnt_fit_strg(_SRC: InvSlotUI, gcGRID: GridContainer, intSlotIndex: int):
	# - - Update Data then UI
	# UI
	var handle_to_source_slot = gcGRID.get_child(intSlotIndex)
	if leftover_delta <= 0:
		handle_to_source_slot.slot.clear()
	else:
		handle_to_source_slot.slot.set_quantity(leftover_delta)

func _transfer_inv_to_storage_JustOne(gcGRID_DEST: GridContainer,slotIndex: int):
	var item = load(ptrINVENTORY[slotIndex][0])
	var amount = ptrINVENTORY[slotIndex][1]
	var remaining:int  = int(amount)
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	for slot in slots:
		if slot.slot.item == item and int(slot.slot.quantity) < item.max_stack:
			var to_add = 1
			slot.qty_label.text = str(int(slot.qty_label.text) + to_add)
			slot.slot.quantity = int(slot.qty_label.text)
			slot.update_ui()
			remaining -= to_add
			leftover_delta = remaining
			return true  # Done adding
	# Step 2: Fill new empty slots
	for slot in slots:
		if slot.slot.item == null:
			var to_add = 1
			slot.slot.item = item
			var new_qty = str(int(slot.qty_label.text) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = int(new_qty)
			slot.update_ui()
			remaining -= to_add
			leftover_delta = remaining
			return true  # Done adding
	## Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func handle_click_StrgToInv_OnlyOne(SRC: InvSlotUI,gcGRID_STRG: GridContainer,gcGRID_INV: GridContainer, intSlotIndex: int):
	if SRC.slot.item != null:
		_transfer_storage_to_inv_JustOne(SRC,gcGRID_INV,intSlotIndex)
		_return_what_didnt_fit_strg(SRC,gcGRID_STRG,intSlotIndex)
		leftover_delta = 0

func _transfer_storage_to_inv_JustOne(SRC: InvSlotUI,gcGRID_DEST: GridContainer,_slotIndex: int):
	var item = SRC.slot.item
	var amount = int(SRC.slot.quantity)
	var remaining = amount
	var destIndex: int = 0
	
	# Step 1: Fill existing stacks
	var slots = gcGRID_DEST.get_children()
	destIndex = 0
	for slot in slots:
		if slot.slot.item == item and int(slot.slot.quantity) < item.max_stack:
			var to_add = 1
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = int(new_qty)
			slot.update_ui()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			leftover_delta = remaining
			return true  # Done adding
			
		destIndex += 1
	# Step 2: Fill new empty slots
	destIndex = 0
	for slot in slots:
		if slot.slot.item == null:
			var to_add = 1
			slot.slot.item = item
			var new_qty = str(int(ptrINVENTORY[destIndex][1]) + to_add)
			slot.qty_label.text = new_qty
			slot.slot.quantity = int(new_qty)
			slot.update_ui()
			remaining -= to_add
			
			# Update DATA here
			ptrINVENTORY[destIndex][0] = item.resource_path
			ptrINVENTORY[destIndex][1] = new_qty
			
			leftover_delta = remaining
			return true  # Done adding
			
		destIndex += 1
	# Step 3: Not enough space
	if remaining > 0:
		print("Not enough space to add item: %s (Missing %d)" % [item.name, remaining])
		leftover_delta = remaining
		return false

func sort_and_combine_inventory_Inv(inventory: Dictionary):
	var item_totals := {}

	# --- Collect totals ---
	for slot_index in inventory.keys():

		var slot = inventory[slot_index]
		var path = slot[0]
		var qty = slot[1]

		if path == null:
			continue

		var item
		if path is String:
			item = load(path)
		else:
			item = load(path.resource_path)

		if item_totals.has(item):
			item_totals[item] += int(qty)
		else:
			item_totals[item] = int(qty)

	# --- Clear all slots ---
	for slot_index in inventory.keys():
		inventory[slot_index] = [null, 0, true]

	# --- Rebuild stacks ---
	var slot_keys = inventory.keys()
	slot_keys.sort()

	var slot_pointer := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_pointer < slot_keys.size():

			var stack_size: int = min(item.max_stack, remaining)
			var slot_index = slot_keys[slot_pointer]

			inventory[slot_index] = [
				item.resource_path,
				stack_size,
				true
			]

			remaining -= stack_size
			slot_pointer += 1

func sort_and_combine_inventory_Strg(grid: GridContainer):
	var slots := grid.get_children()
	var item_totals := {}

	# Collect all quantities
	for slot in slots:
		if slot.slot.item != null:
			var qty := int(slot.slot.quantity)

			if item_totals.has(slot.slot.item):
				item_totals[slot.slot.item] += qty
			else:
				item_totals[slot.slot.item] = qty

	# Clear all slots
	for slot in slots:
		slot.slot.item = null
		slot.icon.texture = null
		slot.qty_label.text = ""
		slot.slot.quantity = int(0)

	# Rebuild stacks
	var slot_index := 0

	for item in item_totals.keys():

		var remaining: int = item_totals[item]

		while remaining > 0 and slot_index < slots.size():

			var stack_size: int = min(item.max_stack, remaining)
			var slot = slots[slot_index]

			slot.slot.item = item
			slot.icon.texture = item.icon
			slot.qty_label.text = str(stack_size)
			slot.slot.quantity = int(slot.qty_label.text)
			slot.update_ui()

			remaining -= stack_size
			slot_index += 1

func try_add_item_to_inventory(inventory: Dictionary, item_name: String, quantity: int) -> int:
	var res = get_resource_by_name(item_name)
	var item_path = res.resource_path
	var item = load(item_path)
	var max_stack = item.max_stack
	
	# --- Step 1: Fill existing stacks ---
	for key in inventory.keys():
		var slot = inventory[key]
		if slot[0] == item_path:
			var current_qty = int(slot[1])
			var space = int(max_stack) - int(current_qty)
			if space > 0:
				var add = min(space, quantity)
				slot[1] = str(int(slot[1]) + int(add))
				quantity -= int(add)
				if quantity <= 0:
					return 0

	# --- Step 2: Use empty slots ---
	var keys = inventory.keys()
	keys.sort()
	for key in keys:
		if quantity <= 0:
			break
		var slot = inventory[key]
		if slot[0] == null:
			var stack_size = min(max_stack, quantity)
			inventory[key] = [
				item_path,
				stack_size,
				true
			]
			quantity -= stack_size

	return quantity

func try_add_item_to_container(container: Array, item_name: String, quantity: int) -> int:
	var res = get_resource_by_name(item_name)
	var item_path = res.resource_path
	var item = load(item_path)
	var max_stack = item.max_stack

	# Fill existing stacks
	for slot_ui in container:
		if slot_ui.slot.item == null:
			continue

		if slot_ui.slot.item.resource_path == item_path:
			var space = max_stack - slot_ui.slot.quantity

			if space > 0:
				var add_amount = min(space, quantity)

				slot_ui.slot.set_quantity(
					slot_ui.slot.quantity + add_amount
				)

				quantity -= add_amount

				if quantity <= 0:
					return 0

	# Fill empty slots
	for slot_ui in container:

		if slot_ui.slot.item == null:

			var stack_size = min(max_stack, quantity)

			slot_ui.slot.set_item(item)
			slot_ui.slot.set_quantity(stack_size)

			quantity -= stack_size

			if quantity <= 0:
				return 0

	return quantity

func is_space_avail_in_inventory(item_name: String, amount: int, inventory: Dictionary)->bool:
	var res = get_resource_by_name(item_name)
	var item_path = res.resource_path
	var item = load(item_path)
	
	var max_stack = item.max_stack
	var remaining := amount
	
	for slot in inventory.values():
		var slot_item = slot[0]
		var quantity = slot[1]
		var usable = slot[2]
		# Skip unusable slots
		if not usable:
			continue
		# Case 1: Same item → fill stack
		if slot_item == item_path:
			var space = max_stack - int(quantity)
			if space > 0:
				var added = min(space, remaining)
				remaining -= added
		# Case 2: Empty slot → new stack
		elif slot_item == null:
			var added = min(max_stack, remaining)
			remaining -= added
		# Early exit if fully placed
		if remaining <= 0:
			return true
	return false

func inventory_has_item(inventory: Dictionary, item_path: String) -> bool:
	for slot in inventory.values():
		if slot[0] == item_path and int(slot[1]) > int(0):
			return true
	return false

func get_resource_by_name(nm: String) -> Resource:
	var tmp_res
	if ResourceLoader.exists(nm):
		tmp_res = load(nm)
	if tmp_res:
		var tmp_nm = tmp_res.name
		return ITEM_REGISTRY.get(tmp_nm, null) 
	else:
		return ITEM_REGISTRY.get(nm, null)



### - Transfer All Items to Inventory
func move_all_to_inventory(container: Array, inventory: Dictionary):

	for slot in container:

		if slot.slot.item == null:
			continue

		var item = slot.slot.item
		var qty = slot.slot.quantity
		
		#var remaining = 0
		#if is_space_avail_in_inventory(item.resource_path,qty,GameManager.PLAYER_INVENTORY_TEST): 
		var remaining = try_add_item_to_inventory(
				inventory,
				item.resource_path,
				qty
			)

		if remaining == 0:
			slot.slot.clear()
		else:
			slot.slot.set_quantity(remaining)


### - Transfer Like Items to Inventory
func collect_similar_from_chest(storage_slots: Array, inventory: Dictionary) -> void:
	# --- STEP 1: Build list of unique item types from storage ---
	var item_types := []
	for chest_slot in storage_slots:
		if chest_slot.slot.item == null:
			continue
		var item_path = chest_slot.slot.item.resource_path

		# Add if not already in the list
		var already_in_list := false
		for existing in item_types:
			if existing == item_path:
				already_in_list = true
				break
		if not already_in_list:
			item_types.append(item_path)

	# --- STEP 2: Process each item type ---
	for item_path in item_types:

		# Check if item exists anywhere in inventory
		var exists := false
		for i in inventory.keys():
			var inv_slot = inventory[i]
			if inv_slot[2] and inv_slot[0] == item_path:
				exists = true
				break
		if not exists:
			continue

		var item_res = load(item_path)
		var max_stack = item_res.max_stack

		# --- PASS 1: Fill existing stacks ---
		for i in inventory.keys():
			var inv_slot = inventory[i]
			if not inv_slot[2]:
				continue
			if inv_slot[0] != item_path:
				continue

			var space = max_stack - int(inv_slot[1])
			if space <= 0:
				continue

			# Pull directly from storage slots
			for chest_index in range(storage_slots.size()):
				var chest_slot = storage_slots[chest_index]
				if chest_slot.slot.item == null:
					continue
				if chest_slot.slot.item.resource_path != item_path:
					continue

				if space <= 0:
					break

				var chest_qty = int(chest_slot.qty_label.text)
				if chest_qty <= 0:
					continue

				var transfer = min(space, chest_qty)

				# Apply transfer
				inv_slot[1] = int(inv_slot[1]) + transfer
				inventory[i] = inv_slot

				chest_qty -= transfer
				chest_slot.qty_label.text = str(chest_qty)
				if chest_qty <= 0:
					chest_slot.slot.item = null
					chest_slot.icon.texture = null
					chest_slot.qty_label.text = ""

				space -= transfer

		# --- PASS 2: Fill empty inventory slots ---
		for i in inventory.keys():
			var inv_slot = inventory[i]
			
			# skip occupied
			var qty = int(inv_slot[1])
			if  qty > int(0):
				continue
			
			# Pull from next storage slot with this item type
			for chest_index in range(storage_slots.size()):
				var chest_slot = storage_slots[chest_index]
				if chest_slot.slot.item == null:
					continue
				if chest_slot.slot.item.resource_path != item_path:
					continue
			
				var chest_qty = int(chest_slot.qty_label.text)
				if chest_qty <= 0:
					continue

				var transfer = min(max_stack, chest_qty)

				inventory[i] = [item_path, transfer, true]

				chest_qty -= transfer
				chest_slot.qty_label.text = str(chest_qty)
				if chest_qty <= 0:
					chest_slot.slot.item = null
					chest_slot.icon.texture = null
					chest_slot.qty_label.text = ""

				break  # move to next inventory slot

### - Transfer Like Items to StorageS
func collect_similar_to_chest(storage_slots: Array, inventory: Dictionary) -> void:

	# Build list of item types already in storage
	var item_types := []

	for chest_slot in storage_slots:
		if chest_slot.slot.item == null:
			continue

		var item_path = chest_slot.slot.item.resource_path

		if not item_types.has(item_path):
			item_types.append(item_path)

	# Process each item type
	for item_path in item_types:

		var item_res = load(item_path)
		var max_stack = item_res.max_stack

		# PASS 1 - Fill existing chest stacks
		for chest_slot in storage_slots:

			if chest_slot.slot.item == null:
				continue

			if chest_slot.slot.item.resource_path != item_path:
				continue

			var space = max_stack - chest_slot.slot.quantity

			if space <= 0:
				continue

			# Pull from inventory
			for key in inventory.keys():

				var inv_slot = inventory[key]

				if inv_slot[0] != item_path:
					continue

				var inv_qty = int(inv_slot[1])

				if inv_qty <= 0:
					continue

				var transfer = min(space, inv_qty)

				chest_slot.slot.set_quantity(
					chest_slot.slot.quantity + transfer
				)

				inventory[key][1] = inv_qty - transfer

				if inventory[key][1] <= 0:
					inventory[key] = [null, 0, true]

				space -= transfer

				if space <= 0:
					break

		# PASS 2 - Fill empty chest slots
		for chest_slot in storage_slots:

			if chest_slot.slot.item != null:
				continue

			for key in inventory.keys():

				var inv_slot = inventory[key]

				if inv_slot[0] != item_path:
					continue

				var inv_qty = int(inv_slot[1])

				if inv_qty <= 0:
					continue

				var transfer = min(max_stack, inv_qty)

				chest_slot.slot.set_item(load(item_path))
				chest_slot.slot.set_quantity(transfer)

				inventory[key][1] = inv_qty - transfer

				if inventory[key][1] <= 0:
					inventory[key] = [null, 0, true]

				break

### - Transfer All Items to Storage
func move_all_to_container(inventory: Dictionary, container: Array):

	for slot_index in inventory:

		var slot_data = inventory[slot_index]

		if slot_data[0] == null:
			continue

		var item_path = slot_data[0]
		var qty = slot_data[1]

		var remaining = StorageManager.try_add_item_to_container(
			container,
			item_path,
			int(qty)
		)

		if remaining == 0:
			inventory[slot_index][0] = null
			inventory[slot_index][1] = 0
		else:
			inventory[slot_index][1] = remaining



func dbg(msg):
	if DEBUG_COLLECT:
		print("[COLLECT] ", msg)

func find_anywhere(name1: String) -> Node:
	var tree := get_tree()
	
	# 1. Try to get autoloads
	var autoloads = ProjectSettings.get_setting("application/config/autoloads")
	if autoloads != null:
		for autoload_name in autoloads.keys():
			var singleton = tree.get_first_node_in_group(autoload_name)
			if singleton:
				if singleton.name == name1:
					return singleton
				var found = singleton.find_child(name1, true)
				if found:
					return found

	# 2. Try current scene
	if tree:
		if tree.current_scene:
			var found = tree.current_scene.find_child(name1, true)
			if found:
				return found

	# 3. Try the root (includes autoloads + main viewport)
	return tree.root.find_child(name1, true, false)


func load_resources_from_folder(path: String) -> Array:
	var resources: Array = []
	var dir := DirAccess.open(path)

	if dir == null:
		push_error("Could not open folder: " + path)
		return resources

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":
		if !dir.current_is_dir():

			# Optional filtering
			if file_name.ends_with(".tres"):
				var full_path := path.path_join(file_name)

				var resource := load(full_path)

				if resource:
					resources.append(resource)
				else:
					push_warning("Failed to load: " + full_path)

		file_name = dir.get_next()
	dir.list_dir_end()

	return resources




# bottom
