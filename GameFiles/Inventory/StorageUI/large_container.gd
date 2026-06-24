@icon("res://assets/icons/inv_Icons/InventoryContainer.svg")
class_name TestContainerLarge extends GridContainer

@onready var inventory_slot_container: GridContainer = $"../InventorySlotContainer"
@onready var large_container: TestContainerLarge = $"."


var inventory : Array[OptiInventorySlot] = []
var storage_slots : Array[OptiInventorySlot] = []

var preset_container_count = 18

func _ready() -> void:
	_load_slots_from_save()

func _load_slots_from_save():
	print("loading large container contents")
	inventory.resize(GameManager.PLAYER_INVENTORY_TEST_LARGE.size())
	for i in inventory.size():
		inventory[i] = OptiInventorySlot.new()
	storage_slots.resize(preset_container_count)
	for i in preset_container_count:
		storage_slots[i] = OptiInventorySlot.new()
	
	bind_inventory(inventory)
	
	# Hard coded slot contents (STORAGE_TEST_LARGE) for dev
	for k in GameManager.STORAGE_TEST_LARGE.size():
		_set_slot(k)
		storage_slots[k].set_item(load(GameManager.STORAGE_TEST_LARGE[k][0]) if GameManager.STORAGE_TEST_LARGE[k][0] else null)
		storage_slots[k].set_quantity(GameManager.STORAGE_TEST_LARGE[k][1])
	
	bind_storage(storage_slots)


func bind_inventory(inv):
	var ui_slots = inventory_slot_container.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])

func bind_storage(inv):
	var ui_slots = large_container.get_children()
	for i in ui_slots.size():
		ui_slots[i].bind_slot(inv[i])


func _set_slot(indx):
	var ic_children = get_children()
	var slot_for_update: InvSlotUI = ic_children[indx]
	if !slot_for_update.is_connected("gui_input", _slot_gui_input.bind(slot_for_update)):
		slot_for_update.connect("gui_input", _slot_gui_input.bind(slot_for_update))

func _slot_gui_input(event: InputEvent, slot: InvSlotUI):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			var context = {
			"slot_clicked": slot,
			"source": get_parent().get_parent().inventory_container_ui,
			"container": get_parent().get_parent().large_container,
			"slot_index": slot.indx
			}
			StorageManager.move_item_to_inventory(context)
			AudioController.play_sound("sfx_slot_pick")
		if event.button_index == MOUSE_BUTTON_RIGHT && event.pressed:
			var context = {
				"slot_clicked": slot,
				"source": get_parent().inventory_container_ui,
				"container": get_parent().large_container,
				"slot_index": slot.indx
			}
			StorageManager.move_single_item_to_inventory(context)
			AudioController.play_sound("sfx_slot_right_click")


# BOTTOM
