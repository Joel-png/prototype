extends Node3D

class_name fish_manager

var fishes: Array[fish_item]
var fish_name_dictionary: Dictionary

func _ready() -> void:
	new_fish("Test fish", \
		"Cast projectile for {0} damage", \
		[10], \
		["damage_projectile"])
	new_fish("Beta fish", \
		"{0}x damage", \
		[2], \
		["damage_multiplier"])
	new_fish("Redd Fish", \
		"Damage yourself for {0}% current HP + {1}% of your total HP each cast, you gain {2}x damage multiplier", \
		[45, 1, 8], \
		["percent, percent, damage_multiplier"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func new_fish(fish_name: String, description: String, variables: Array, variable_types: Array[String]):
	print(fish_name)
	print(description.format(variables))
	var fish = fish_item.new(fish_name, description, variables, variable_types)
	fishes.append(fish)
	fish_name_dictionary[fish_name] = fish_name_dictionary.size()
	
func cast_fish(fish_name: String):
	return fishes[fish_name_dictionary[fish_name]].cast()
