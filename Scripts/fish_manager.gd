extends Node3D

class_name FishManager

var fishes: Array[FishResource]
var fish_name_dictionary: Dictionary

func _ready() -> void:
	new_fish("Test fish", "cast", preload("res://Assets/Fish/bluefish.png"),\
		"Cast {0} projectile for {1} damage", \
		[1, 10, "fireball", 20], \
		["projectile", "damage", "spell", "cast_cost"])
	new_fish("Beta fish", "all", preload("res://Assets/Fish/redfish.png"),\
		"{0}x damage", \
		[2, 10], \
		["damage_multiplier", "cast_cost"])
	new_fish("Redd Fish", "cast", preload("res://Assets/Fish/bluefish.png"),\
		"Damage yourself for {0}% current HP + {1}% of your total HP each cast, you gain {2}x damage multiplier", \
		[45, 1, 8, "damage_self", 0], \
		["current_hp", "total_hp", "damage_multiplier", "buff", "cast_cost"])
	new_fish("Hit fish", "onhit", preload("res://Assets/Fish/bluefish.png"),\
		"do {0} damage in an {1} meter AOE", \
		[33, 5], \
		["damage", "aoe"])

func new_fish(fish_name: String, proc_type: String, image, description: String, variables: Array, variable_types: Array[String]):
	print(fish_name)
	print(description.format(variables))
	var fish = FishResource.new(fish_name, proc_type, image, description, variables, variable_types)
	fishes.append(fish)
	fish_name_dictionary[fish_name] = fish_name_dictionary.size()
	
func cast_fish(fish_to_cast, proc_type: String):
	var fish = fish_to_cast
	if fish.is_proc_type(proc_type) or fish.is_proc_type("all"):
		return [fish.get_dictionary(), fish.get_variable_types()]
	else:
		return []

func cast_fish_from_name(fish_name: String, proc_type: String):
	var fish = fishes[fish_name_dictionary[fish_name]]
	if fish.is_proc_type(proc_type) or fish.is_proc_type("all"):
		return [fish.get_dictionary(), fish.get_variable_types()]
	else:
		return []

func get_new_fish_from_name(fish_name: String):
	var new_fish = fishes[fish_name_dictionary[fish_name]].dup()
	return new_fish
