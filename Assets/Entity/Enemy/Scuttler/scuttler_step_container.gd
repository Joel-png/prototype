extends Node3D

@export var offset: float = 1.0 / 3.0
@export var curve: Curve

@onready var parent = get_parent_node_3d()
@onready var previous_position = parent.global_position
var i = 0

func _process(delta: float) -> void:
	var velocity = (parent.global_position - previous_position) / delta
	var speed_per_sec : float = parent.global_position.distance_to(previous_position) / delta
	i += 1
	if i % 100 == 0:
		print(velocity)
	global_position = parent.global_position + velocity * offset
	
	previous_position = parent.global_position
