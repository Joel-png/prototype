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
		look_at_position(closets_player_position, delta)
	

func look_at_position(target_position, delta):
	var rotation_speed = 2.0
	var direction = (target_position - eye.global_position)
	var direction_x_z = pow(pow(direction.x, 2) + pow(direction.z, 2), 0.5)
	var angle_pitch = atan2(direction_x_z, direction.y) + PI/2.0
	var angle_yaw = -atan2(direction.z, direction.x) + PI/2.0
	
	eye.rotation.y = lerp_angle(eye.rotation.y, angle_yaw, rotation_speed * delta)
	eye.rotation.x = lerp_angle(eye.rotation.x, angle_pitch, rotation_speed * delta)

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
