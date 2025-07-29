extends Holdable
class_name Rod

var base_action_cooldown: float = 1
var action_cooldown: float = 1
var cast_speed: float = 2.0
var random_scaler = 0.5

@onready var fish_manager = get_tree().get_nodes_in_group("FishManager")[0]

func _ready() -> void:
	overseer = get_parent().player
	

func action(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		fish()

func fish():
	var random_droprate = fish_manager.get_random_droprate()
	print(random_droprate)
	var new_fish = fish_manager.get_fish_from_droprate(random_droprate)
	new_fish.rarity = set_rarity()
	new_fish.apply_rarity_to_variables()
	overseer.inventory.add_item(new_fish)

func set_rarity():
	var rarity = (1.0 - 1.0 * random_scaler) + (int)(randi_range(1, 100) * random_scaler) / 100.0
	rarity = min(1.0, rarity)
	return rarity
