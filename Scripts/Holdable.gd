extends Node3D
class_name Holdable

var overseer
var scene
var scene_to_set
var selected: bool = false

func _ready() -> void:
	visible = false

func init(new_overseer) -> void:
	overseer = new_overseer
	#add_to_parent()
	visible = true

func action(_delta: float) -> void:
	return

func end_action(_delta: float) -> void:
	return

func public_end_action(_delta: float) -> void:
	return

func add_to_parent() -> void:
	overseer.inventory.add_child(self)

@rpc("any_peer", "call_local")
func deselect() -> void:
	selected = false
	visible = false
	
@rpc("any_peer", "call_local")
func select() -> void:
	selected = true
	visible = true

func get_scene():
	return scene

func is_focus():
	if overseer != null:
		if overseer.is_focus:
			return true
	return false
