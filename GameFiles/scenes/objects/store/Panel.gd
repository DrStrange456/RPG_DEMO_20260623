extends Panel

@onready var nm: String
@onready var qty: int
@onready var typ: String

#const ItemClass = preload("res://GameData/NewInventory/item.gd")

func _physics_process(_delta):
	if typ:
		$TextureRect.texture = load("res://assets/icons/" + typ + ".png")
