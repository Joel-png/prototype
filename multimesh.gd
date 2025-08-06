extends MultiMeshInstance3D

@export var min_distance := 20.0
@export var max_distance := 40.0

@onready var mm := multimesh

func _process(_delta):
	if $"..".generated:
		var player_pos = get_tree().get_nodes_in_group("MainPlayer")[0].global_position
		
		for i in mm.instance_count:
			var xf = mm.get_instance_transform(i)
			var dist = xf.origin.distance_to(player_pos)

			var fade := 1.0
			if dist > max_distance:
				fade = 0.0
			elif dist > min_distance:
				fade = 1.0 - ((dist - min_distance) / (max_distance - min_distance))

			var color = Color(0, 0, 0, fade) # A = fade
			mm.set_instance_custom_data(i, color)
