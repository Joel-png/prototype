extends Node3D
class_name Holdable

var overseer
var scene
var scene_to_set

func _init(new_overseer):
	overseer = new_overseer
	if scene_to_set:
		scene = overseer.spawn_holdable(scene_to_set)
		add_to_parent()
	
	
func action():
	return
	
func end_action():
	return

func add_to_parent():
	overseer.inventory.add_child(scene)
	
func deselect():
	scene.visible = false
	
func select():
	scene.visible = true

func get_scene():
	return scene

func get_self():
	return self
