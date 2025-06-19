extends Node3D

@export var group_name: String = ""
var group_members
var counter = 0
var print = false

func _process(delta: float):
	if counter >= 0.0:
		counter -= 1.0 * delta
		print = false
	else:
		counter += 1.0
		print = true
	
func find_position():
	var pos = Vector3(0.0, 0.0, 0.0)
	var found = false
	group_members = get_tree().get_nodes_in_group(group_name)
	var noisiest = 0.0
	for member in group_members:
		found = has_line_of_sight(member)
		if print:
			print(found)
		if found and member.noise_level > noisiest:
			noisiest = member.noise_level
			pos = member.position
	if print:
		print([noisiest > 0.0, pos])
	return [noisiest > 0.0, pos]

func has_line_of_sight(player):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(player.global_position + Vector3(0.0, 1.0, 0.0), global_position)
	query.collision_mask = 1
	query.exclude = [self, player]
	var result = space_state.intersect_ray(query)
	return result.is_empty()
	
		
	
