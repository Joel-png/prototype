extends CharacterBody3D

@onready var eye = $Eye
@onready var eye_mesh = $Eye/EyeballMesh
@onready var detection_area = $DetectionArea
var counter = 0

func _process(delta):
	if detection_area.has_overlapping_bodies():
		var detected_players = detection_area.get_overlapping_bodies()
		var closests_player_index = get_closest_player_index(detected_players)
		var closets_player_position = detected_players[closests_player_index].position
		lerp_look_at(self, closets_player_position, delta, 0.1)
		lerp_look_at(eye, closets_player_position, delta, 4.0)
		#eye_look_at_position(closets_player_position, delta, 2.0)

func lerp_look_at(thing_looking, target_position, delta, rotation_speed):
	var old_rotation = thing_looking.rotation
	print(old_rotation)
	thing_looking.look_at(target_position)
	var new_rotation = thing_looking.rotation
	thing_looking.rotation = old_rotation
	thing_looking.rotate_y(((new_rotation.y - old_rotation.y) * delta * rotation_speed))
	thing_looking.rotate_x(((new_rotation.x - old_rotation.x) * delta * rotation_speed))
	thing_looking.rotation.z = 0
	

func get_closest_player_index(players):
	var overlapping_bodies = players
	var closests_body_distance = position.distance_to(overlapping_bodies[0].position)
	var closests_body_index = 0
	for body_index in range(1, overlapping_bodies.size()):
		var distance_to_player = position.distance_to(overlapping_bodies[body_index].position)
		if distance_to_player < closests_body_distance:
			closests_body_distance = distance_to_player
			closests_body_index = body_index
	return closests_body_index
	
### this function is useless since making a better lerp_look_at but this took so long I can't bring myself to delte it
#func look_at_position(thing_looking, target_position, delta, rotation_speed):
	#var direction = (target_position - thing_looking.position)
	#var direction_x_z = pow(pow(direction.x, 2) + pow(direction.z, 2), 0.5)
	#var angle_pitch = -atan2(direction_x_z, direction.y) + PI/2.0
	#var angle_yaw = -atan2(direction.z, direction.x) - PI/2.0
	#
	#thing_looking.rotation.y = lerp_angle(thing_looking.rotation.y, angle_yaw, rotation_speed * delta)
	#thing_looking.rotation.x = lerp_angle(thing_looking.rotation.x, angle_pitch, rotation_speed * delta)
