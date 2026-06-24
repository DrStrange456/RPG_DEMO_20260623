extends Node2D

signal activate_clicked

var player_within_range: bool = false
var plyr



func _ready() -> void:
	Events.connect("show_shop_icon", Callable(_set_market_open))
	Events.connect("hide_shop_icon", Callable(_set_market_closed))


func _input(_event: InputEvent) -> void:
	if plyr and player_within_range:
		if Input.is_action_just_pressed("ui_cancel"):
			GameManager.glPlayerRef._attempt_exit_store()
			get_viewport().set_input_as_handled()  # Mark event as handled
		
		if Input.is_action_just_pressed("activate"):
			var gen_str = FuncLibrary.find_anywhere("general_store")
			gen_str.visible = true
			UiManager.active_ui = gen_str
			GameManager.glPlayerRef.state = Enum.State.SHOP
			get_viewport().set_input_as_handled()  # Mark event as handled



func is_player_interacting()->bool:
	return player_within_range


func interact():
	print("Store opening")

func _set_market_closed():
	if $interact_icon.visible:
		$interact_icon.visible = false

func _set_market_open():
	if !$interact_icon.visible:
		$interact_icon.visible = true





func interact_enabled(body: Node2D):
	if body.is_in_group("player"):
		#$interact_icon.visible = true
		Events.emit_signal("show_shop_icon")
		player_within_range = true
		plyr = body

func interact_disabled(body: Node2D):
	if body.is_in_group("player"):
		#$interact_icon.visible = false
		Events.emit_signal("hide_shop_icon")
		player_within_range = false
		plyr = body
