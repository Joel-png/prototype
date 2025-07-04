extends Node3D

class_name fish_manager

var fishes: Array[fish_item]
var fish_name_dictionary: Dictionary

func _ready() -> void:
	new_fish("Test fish", "cast", \
		"Cast {0} projectile for {1} damage", \
		[1, 10, "fireball", 20], \
		["projectile", "damage", "spell", "cast_cost"])
	new_fish("Beta fish", "all", \
		"{0}x damage", \
		[2, 10], \
		["damage_multiplier", "cast_cost"])
	new_fish("Redd Fish", "cast", \
		"Damage yourself for {0}% current HP + {1}% of your total HP each cast, you gain {2}x damage multiplier", \
		[45, 1, 8, "damage_self", 0], \
		["current_hp", "total_hp", "damage_multiplier", "buff", "cast_cost"])
	new_fish("Hit fish", "onhit", \
		"do {0} damage in an {1} meter AOE", \
		[33, 5], \
		["damage", "aoe"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_fish(fish_name: String, proc_type: String, description: String, variables: Array, variable_types: Array[String]):
	print(fish_name)
	print(description.format(variables))
	var fish = fish_item.new(fish_name, proc_type, description, variables, variable_types)
	fishes.append(fish)
	fish_name_dictionary[fish_name] = fish_name_dictionary.size()
	
func cast_fish(fish_name: String, proc_type: String):
	var fish = fishes[fish_name_dictionary[fish_name]]
	if fish.is_proc_type(proc_type) or fish.is_proc_type("all"):
		return [fish.get_dictionary(), fish.get_variable_types()]
	else:
		return []
