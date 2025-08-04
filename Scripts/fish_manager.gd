extends Node3D

class_name FishManager

var fishes: Array[FishResource]
var fish_name_dictionary: Dictionary
var random_droprate: int

func _ready() -> void:
	# Data types for fish
	# projectile - times spell is cast
	# damage - damage of spell
	# cast_cost - cost to cast
	# spell - name of spell
	# damage_multiplier - <- that
	
	new_fish("Test fish", "cast", preload("res://Assets/Fish/bluefish.png"),\
		"Cast {0} projectile for {1} damage", \
		1, \
		[1, 10, 20, "fireball"], \
		["projectile", "damage", "cast_cost", "spell"], \
		["damage"])
	new_fish("Beta fish", "all", preload("res://Assets/Fish/redfish.png"),\
		"{0}x damage", \
		1, \
		[2, 10], \
		["damage_multiplier", "cast_cost"], \
		["damage_multiplier"])
	new_fish("Redd Fish", "cast", preload("res://Assets/Fish/bluefish.png"),\
		"Damage yourself for {0}% current HP + {1}% of your total HP each cast, you gain {2}x damage multiplier", \
		1, \
		[45, 1, 8, "damage_self", 0], \
		["current_hp", "total_hp", "damage_multiplier", "buff", "cast_cost"], \
		[])
	new_fish("Hit fish", "onhit", preload("res://Assets/Fish/bluefish.png"),\
		"do {0} damage in an {1} meter AOE", \
		1, \
		[33, 5], \
		["damage", "aoe"], \
		[])
		
	random_droprate = get_total_droprate()

func get_total_droprate():
	var total_droprate = 0
	for fish in fishes:
		total_droprate += fish.droprate
	return total_droprate

func get_random_droprate():
	return randi_range(1, random_droprate)

func get_fish_from_droprate(droprate: int):
	var total_droprate = 0
	for fish in fishes:
		total_droprate += fish.droprate
		if total_droprate >= droprate:
			return fish.dup()
		

func new_fish(fish_name: String, proc_type: String, image, description: String, droprate: int, variables: Array, variable_types: Array[String], variable_rarity: Array[String]):
	#print(fish_name)
	#print(description.format(variables))
	var fish = FishResource.new(fish_name, proc_type, image, description, droprate, variables, variable_types, variable_rarity)
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
	var new_fish_from_name = fishes[fish_name_dictionary[fish_name]].dup()
	return new_fish_from_name
