# item.gd
class_name Item extends Resource

@export var name: String
@export var description: String
@export var icon: Texture2D
@export var cost: int
@export var item_type: String = "Generic"
@export var max_stack: int = 99  # Default to 99, or 1 for non-stackable

@export_category("enums")
@export var enum_seed_value: Enum.Seed
@export var enum_seed_item_value: Enum.Item

@export_category("misc")
@export var crafting_requirements: Dictionary = {}  # { "Wood": 2, "Iron": 1 }
@export var equip_type: String = ""  # e.g., "weapon", "head", etc.
@export var is_equippable: bool = false
@export var attack_power_max: int
@export var attack_power_min: int
@export var attack_speed: float = 0.25
@export var defense_power: float = 1.0
@export var defense_reflect: bool = false
