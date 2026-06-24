extends Node

#func _ready():
	#print("Events ready at: ", Time.get_ticks_msec())

# Sample Call:
# Events.emit_signal("hide_shop_icon")

# Sample connect:
# Events.connect("<signal_name>", Callable(<function_to_run>))

signal try_interact_sm_chest
signal try_interact_lg_chest
signal try_interact_merchant

signal show_shop_icon
signal hide_shop_icon
signal refresh_market_inv_ui
signal settings_video_pressed
signal update_weapon_button
signal update_tool_button
signal update_item_button

signal hide_buttons_and_tod
signal show_buttons_and_tod
