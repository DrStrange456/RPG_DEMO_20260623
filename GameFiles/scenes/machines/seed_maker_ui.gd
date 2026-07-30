extends popup_ui

@export var machine_obj: StaticBody2D


@onready var slot_in: Panel = $PopupRoot/Panel/panel_left/slot_in
@onready var slot_in_label: Label = $PopupRoot/Panel/panel_left/Label
@onready var slot_out: Panel = $PopupRoot/Panel/panel_left/slot_out
@onready var slot_out_label: Label = $PopupRoot/Panel/panel_left/Label2
@onready var grid_container: GridContainer = $PopupRoot/Panel/panel_right/GridContainer
@onready var progress_bar: ProgressBar = $PopupRoot/Panel/ProgressBar
@onready var btn_collect: Button = $PopupRoot/Panel/btnCOLLECT

var selected_crop = preload("res://resources/crop_carrot.tres")



func _ready() -> void:
	slot_in_label.text = ""
	slot_out_label.text = ""

func _process(delta):
	
	if machine_obj == null:
		return
	
	progress_bar.visible = machine_obj.state == machine_obj.State.PROCESSING
	
	#print(machine_obj.timer.wait_time)
	
	
	if machine_obj.state == machine_obj.State.PROCESSING:
		progress_bar.value = (
			(machine_obj.timer.wait_time - machine_obj.timer.time_left)
			/ machine_obj.timer.wait_time
		) * 100
		
		print(machine_obj.timer.time_left)
	
	btn_collect.visible = machine_obj.state == machine_obj.State.FINISHED




func _on_button_pressed() -> void:
	machine_obj.start_processing(selected_crop)

func _on_btn_collect_pressed() -> void:
	machine_obj.collect()



func _on_button_2_pressed() -> void:
	_reset()




func _move_selected_to_in():
	var gv_itms = grid_container.get_children()
	var item_from_gv = gv_itms[0].get_child(0).get_child(0)
	var dest_slot    = slot_in.get_child(0).get_child(0)
	dest_slot.texture = item_from_gv.texture
	print("test")

func _reset():
	var src_slot    = slot_in.get_child(0).get_child(0)
	src_slot.texture = null
	var dest_slot   = slot_out.get_child(0).get_child(0)
	dest_slot.texture = null
	slot_in_label.text = ""
	slot_out_label.text = ""
