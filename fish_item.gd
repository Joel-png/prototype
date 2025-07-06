extends Node3D

var fish_resource: FishResource
@onready var fish_manager = get_tree().get_nodes_in_group("FishManager")[0]

func set_fish(fish_name: String):
	fish_resource = fish_manager.get_new_fish_from_name(fish_name)
