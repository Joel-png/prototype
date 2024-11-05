extends CharacterBody3D

var move_speed: float = 30.0
var distance_to_attack: float = 50.0
var turn_speed: float = 1.0
var ground_offset: float = 1.5
var last_seen_player
var attacking: bool = false

@onready var detection_area = $BaseArmature_001/Skeleton3D/FullBody/Eye/DetectionArea
@onready var eye = $BaseArmature_001/Skeleton3D/FullBody/Eye

@onready var attack_timer = $AttackTimer

@onready var fl_leg = $BaseArmature_001/Skeleton3D/IKFrontL
@onready var bl_leg = $BaseArmature_001/Skeleton3D/IKBackL
@onready var fr_leg = $BaseArmature_001/Skeleton3D/IKFrontR
@onready var br_leg = $BaseArmature_001/Skeleton3D/IKBackR

func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * 4 * delta
	
	#follow if not attacking
	if not attacking:
		if detection_area.has_overlapping_bodies():
			var detected_players: Array = detection_area.get_overlapping_bodies()
			var closests_player_index: int = get_closest_player_index(detected_players)
			var closest_player_position: Vector3 = detected_players[closests_player_index].position
			last_seen_player = detected_players[closests_player_index]
			lerp_angle_look_at(closest_player_position, delta, 0.9)
			lerp_look_at(eye, closest_player_position, delta, 0.95)
			
			set_vel(move_speed * delta)
		elif last_seen_player:
			var closest_player_position: Vector3 = last_seen_player.position
			lerp_angle_look_at(closest_player_position, delta, 0.9)
			lerp_look_at(eye, closest_player_position, delta, 0.95)
			
			set_vel(move_speed * 3.0 * delta)
			
		#close to play start attack
		if last_seen_player:
			var distance_to_player = last_seen_player.position.distance_to(global_position)
			if distance_to_player < distance_to_attack:
				attacking = true
				attack_timer.start()
				print("attacking")
				
	else:
		set_vel(move_speed * 3.0 * delta)
		if attack_timer.is_stopped():
			attacking = false
			print("stopped attacking")
		
	move_and_slide()

func set_vel(move_amount):
	if is_on_floor():
		var forward_direction = -transform.basis.z
		velocity = forward_direction * move_amount * 100.0

func lerp_angle_look_at(target_position: Vector3, delta: float, rotation_speed: float) -> void:
	var direction: Vector3 = (target_position - position)
	#var direction_x_z: float = pow(pow(direction.x, 2) + pow(direction.z, 2), 0.5)
	#var angle_pitch: float = -atan2(direction_x_z, direction.y) + PI/2.0
	var angle_yaw: float = -atan2(direction.z, direction.x) - PI/2.0
	var angle = abs(rotation.y - lerp_angle(rotation.y, angle_yaw, 1.0))
	if angle > 0.5:
		rotation_speed *= 4.0
		velocity.x *= 0.1
		velocity.z *= 0.1
	rotation.y = lerp_angle(rotation.y, angle_yaw, rotation_speed * delta)

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
