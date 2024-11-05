extends CharacterBody3D

var move_speed: float = 5.0
var turn_speed: float = 1.0
var ground_offset: float = 1.5

@onready var detection_area = $Eye/DetectionArea
@onready var eye = $Eye

@onready var fl_leg = $BaseArmature_001/Skeleton3D/IKFrontL
@onready var bl_leg = $BaseArmature_001/Skeleton3D/IKBackL
@onready var fr_leg = $BaseArmature_001/Skeleton3D/IKFrontR
@onready var br_leg = $BaseArmature_001/Skeleton3D/IKBackR

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 4.0 * delta
	else:
		var forward_direction = -transform.basis.z
		velocity = forward_direction * move_speed * delta * 100.0
	
	if detection_area.has_overlapping_bodies():
		var detected_players: Array = detection_area.get_overlapping_bodies()
		var closests_player_index: int = get_closest_player_index(detected_players)
		var closets_player_position: Vector3 = detected_players[closests_player_index].position
		lerp_angle_look_at(self, closets_player_position, delta, 0.7)
		lerp_look_at(eye, closets_player_position, delta, 0.8)
		
	move_and_slide()

func lerp_angle_look_at(thing_looking, target_position: Vector3, delta: float, rotation_speed: float) -> void:
	var direction: Vector3 = (target_position - position)
	var direction_x_z: float = pow(pow(direction.x, 2) + pow(direction.z, 2), 0.5)
	var angle_pitch: float = -atan2(direction_x_z, direction.y) + PI/2.0
	var angle_yaw: float = -atan2(direction.z, direction.x) - PI/2.0
	
	rotation.y = lerp_angle(rotation.y, angle_yaw, rotation_speed * delta)
	#thing_looking.rotation.x = lerp_angle(thing_looking.rotation.x, angle_pitch, rotation_speed * delta)

func lerp_look_at(thing_looking, target_position: Vector3, delta: float, rotation_speed: float) -> void:
	var old_rotation: Vector3 = thing_looking.rotation
	thing_looking.look_at(target_position)
	var new_rotation: Vector3 = thing_looking.rotation
	thing_looking.rotation = old_rotation
	thing_looking.rotate_y(((new_rotation.y - old_rotation.y) * delta * rotation_speed))
	thing_looking.rotate_x(((new_rotation.x - old_rotation.x) * delta * rotation_speed))
	thing_looking.rotation.z = 0
	
func get_closest_player_index(players):
	var overlapping_bodies: Array = players
	var closests_body_distance: float = position.distance_to(overlapping_bodies[0].position)
	var closests_body_index: int = 0
	for body_index in range(1, overlapping_bodies.size()):
		var distance_to_player: float = position.distance_to(overlapping_bodies[body_index].position)
		if distance_to_player < closests_body_distance:
			closests_body_distance = distance_to_player
			closests_body_index = body_index
	return closests_body_index
