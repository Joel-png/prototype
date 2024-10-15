extends Node3D
class_name Holdable

var overseer
var scene
var scene_to_set

func init(new_overseer) -> void:
	overseer = new_overseer
	add_to_parent()
	visible = false

func action(_delta: float) -> void:
	return

func end_action() -> void:
	return

func add_to_parent() -> void:
	overseer.inventory.add_child(self)
	
func deselect() -> void:
	visible = false
	
func select() -> void:
	visible = true

func get_scene():
	return scene
