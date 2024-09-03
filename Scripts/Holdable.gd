extends Node3D
class_name Holdable

var overseer
var scene

func _init(new_overseer):
	overseer = new_overseer
	

func action():
	return
	
func end_action():
	return

func deselect():
	scene.visible = false
	
func select():
	scene.visible = true

func get_scene():
	return scene
