extends Node3D
class_name Holdable

var overseer
var scene
var scene_to_set

func init(new_overseer):
	overseer = new_overseer
	add_to_parent()
	visible = false

func action(_delta):
	return

func end_action():
	return

func add_to_parent():
	overseer.inventory.add_child(self)
	
func deselect():
	visible = false
	
func select():
	visible = true

func get_scene():
	return scene
