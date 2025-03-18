extends Node3D

class_name fish_manager

@export var fish: Array[fish_item]

var lamb0 = func(): print("lamb0")
var lamb1 = func(): print("lamb1")
var lambs = [lamb0, lamb1]
func _ready() -> void:
	lambs[0].call()
	lambs[1].call()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
