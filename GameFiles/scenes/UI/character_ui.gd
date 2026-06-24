extends Control

@onready var grid_container: GridContainer = $GridContainer
@onready var btn_seed: Button = $btnSEED
@onready var btn_sword: Button = $btnSWORD
@onready var btn_hoe: Button = $btnHOE



#var slot = GameManager.glSlot
var inventory : Array[OptiInventorySlot] = []
var button_pressed: String = ""



func bind_inventory(inv):
	var ui_slots = grid_container.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

func _set_slot(indx):
	if indx >= 0:
		var ic_children = grid_container.get_children()
		var slot_for_update: InvSlotUI = ic_children[indx]
		if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
			slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, invSlot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			
			match button_pressed:
				"seed_Pack":
					GameManager.selected_item = invSlot.slot.item
					btn_seed.icon = invSlot.slot.item.icon
				"tool":
					GameManager.selected_tool = invSlot.slot.item
					btn_hoe.icon = invSlot.slot.item.icon
				"weapon":
					GameManager.selected_weapon = invSlot.slot.item
					btn_sword.icon = invSlot.slot.item.icon

func _on_btn_seed_pressed() -> void:
	button_pressed = "seed_Pack"
	load_item_type("seed_Pack")

func _on_btn_hoe_pressed() -> void:
	button_pressed = "tool"
	load_item_type("tool")

func _on_btn_sword_pressed() -> void:
	button_pressed = "weapon"
	load_item_type("weapon")


func load_item_type(typ):
	grid_container = $GridContainer
	# Clear container
	for M in grid_container.get_children():
		M.free()
	
#	first get count
	var countMatches: int = 0
	for j in GameManager.PLAYER_INVENTORY_TEST:
		if GameManager.PLAYER_INVENTORY_TEST[j][0] != null:
			if int(GameManager.PLAYER_INVENTORY_TEST[j][1]) > 0:
				var tmpItm: Resource = load(GameManager.PLAYER_INVENTORY_TEST[j][0])
				if tmpItm.item_type == typ:
					
					# UI
					var newNode = GameManager.glSlotUI.instantiate()
					newNode.custom_minimum_size = Vector2(40,40)
					newNode.size = Vector2(40,40)
					grid_container.add_child(newNode)
					
					countMatches += 1
	
	inventory.resize(countMatches)
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
#	populate the grid with only seeds
	var indx = 0
	for j in GameManager.PLAYER_INVENTORY_TEST:
		if GameManager.PLAYER_INVENTORY_TEST[j][0] != null:
			if int(GameManager.PLAYER_INVENTORY_TEST[j][1]) > 0:
				var tmpItm: Resource = load(GameManager.PLAYER_INVENTORY_TEST[j][0])
				var tmpItm_qty: int = int(GameManager.PLAYER_INVENTORY_TEST[j][1])
				if tmpItm.item_type == typ:
					inventory[indx].indx = indx
					inventory[indx].set_item(tmpItm)
					inventory[indx].set_quantity(tmpItm_qty)
					indx += 1
		_set_slot(indx-1)



# BOTTOM
