extends Resource

class_name FishResource

var fish_name: String
var proc_type: String
var description: String
var droprate: int
var variables: Array
var variable_types: Array[String]
var variable_rarity: Array[String]
var variable_dictionary: Dictionary
var image: Texture2D
var rarity: float

func _init(_fish_name: String, _proc_type: String, _image, _description: String, _droprate: int, _variables: Array, _variable_types: Array[String], _variable_rarity: Array[String]) -> void:
	fish_name = _fish_name
	proc_type = _proc_type
	image = _image
	description = _description
	droprate = _droprate
	variables = _variables.duplicate(true)
	variable_types = _variable_types
	variable_rarity = _variable_rarity
	create_dictionary(variable_types, variables)

func create_dictionary(a0: Array, a1: Array):
	for i in range(0, a0.size()):
		variable_dictionary[a0[i]] = a1[i]

func apply_rarity_to_variables():
	for variable_type in variable_types:
		if variable_type in variable_rarity:
			variable_dictionary[variable_type] *= rarity
	for i in range(0, variables.size()):
		if variable_types[i] in variable_rarity:
			variables[i] *= rarity

func is_proc_type(_proc_type: String):
	return _proc_type == proc_type

func get_variables():
	return variables
	
func get_variable_types():
	return variable_types
	
func get_dictionary():
	return variable_dictionary

func dup():
	var new_fish = FishResource.new(fish_name, proc_type, image, description, droprate, variables, variable_types, variable_rarity)
	return new_fish
