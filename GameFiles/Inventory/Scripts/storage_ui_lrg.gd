extends popup_ui


@onready var storage_inventory_control: Control = $PopupRoot/Storage_InventoryControl
@onready var storage_storage_control: Control = $PopupRoot/Storage_StorageControl
@onready var inventory_container_ui: GridContainer = $PopupRoot/InventorySlotContainer
@onready var large_container: gridcontainer_base = $PopupRoot/Storage_StorageControl/Panel/Storage_CoreStorageController
@onready var test_container: gridcontainer_base = $PopupRoot/Storage_StorageControl/Panel/Storage_CoreStorageController

var inventory : Array[OptiInventorySlot] = []





func open_ui():
	storage_inventory_control.initialize()
	storage_storage_control.initialize()


func _on_btn_quit_pressed() -> void:
	Events.try_interact_lg_chest.emit()


# Bottom
