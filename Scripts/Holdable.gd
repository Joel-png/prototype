extends Node3D
class_name Holdable

var overseer
var scene

func _init(new_overseer):
	overseer = new_overseer
	

func action():
	print("Action called on Holdable item")
	
func end_action():
	print("Action called on Holdable item")

func deselect():
	scene.visible = false
	
func select():
	scene.visible = true

func get_scene():
	return scene
