extends Node3D

@export var group_name: String = ""
@export var search_radius: float = 50.0
@export var perfect_hearing_range: float = 20.0
@export var hearing_requirement: float = 20.0
@export var perfect_hearing_added: float = 20.0
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
	var member_noise = 0.0
	for member in group_members:
		found = has_line_of_sight(member)
		member_noise = is_heard(member.global_position, member.noise_level)
		if found and member_noise > noisiest:
			noisiest = member_noise
			pos = member.global_position
		elif member_noise >= hearing_requirement * 4.0:
			noisiest = member_noise
			pos = member.global_position
	if print:
		print([noisiest, pos])
	return [noisiest >= hearing_requirement, pos]

func is_heard(pos, noise):
	var distance_to = global_position.distance_to(pos)
	var distance_scaler = 1.0 - min(distance_to / search_radius, 1.0)
	var hearing_value = noise * distance_scaler
	if distance_to <= perfect_hearing_range:
		hearing_value *= 2.0
		hearing_value += perfect_hearing_added
	if distance_to <= perfect_hearing_range * 10.0 and noise > 5.0 * hearing_requirement:
		hearing_value += perfect_hearing_added * 5.0
	return hearing_value
	
func has_line_of_sight(player):
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(player.global_position + Vector3(0.0, 1.0, 0.0), global_position)
	query.collision_mask = 1
	query.exclude = [self, player]
	var result = space_state.intersect_ray(query)
	return result.is_empty()
