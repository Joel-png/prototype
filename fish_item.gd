extends Resource

class_name fish_item

var fish_name: String
var proc_type: String
var description: String
var variables: Array
var variable_types: Array[String]
var variable_dictionary: Dictionary
var image: Texture2D

func _init(_fish_name: String, _proc_type: String, _description: String, _variables: Array, _variable_types: Array[String]) -> void:
	fish_name = _fish_name
	proc_type = _proc_type
	description = _description
	variables = _variables
	variable_types = _variable_types
	create_dictionary(variable_types, variables)
	
func create_dictionary(a0: Array, a1: Array):
	for i in range(0, a0.size()):
		variable_dictionary[a0[i]] = a1[i]

func is_proc_type(_proc_type: String):
	return _proc_type == proc_type

func get_variables():
	return variables
	
func get_variable_types():
	return variable_types
	
func get_dictionary():
	return variable_dictionary
