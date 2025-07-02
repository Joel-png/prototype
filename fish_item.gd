extends Resource

class_name fish_item

var fish_name: String
var description: String
var variables
var variable_types: Array[String]
var image: Texture2D

func _init(_fish_name: String, _description: String, _variables: Array, _variable_types: Array[String]) -> void:
	fish_name = _fish_name
	description = _description
	variables = _variables
	variable_types = _variable_types
	
func cast():
	var cast_stuff: Array
	for i in range(variables.size()):
		cast_stuff += [variable_types[i], variables[i]]
	return cast_stuff
