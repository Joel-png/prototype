extends CharacterBody3D

var move_speed: float = 20.0
var distance_to_attack: float = 50.0
var turn_speed: float = 1.0
var ground_offset: float = 1.5
var last_seen_player
var path_data

var attacking: bool = false
var attack_charge_time: float = 2.0
var state: String = "search"

var flank_direction: int = 1
var closest_player_position = Vector3(0.0, 0.0, 0.0)

@onready var detection_area = $BaseArmature_001/Skeleton3D/FullBody/Eye/DetectionArea
@onready var eye = $BaseArmature_001/Skeleton3D/FullBody/Eye
@onready var pather = $Pather

@onready var action_timer = $ActionTimer

@onready var fl_leg = $BaseArmature_001/Skeleton3D/IKFrontL
@onready var bl_leg = $BaseArmature_001/Skeleton3D/IKBackL
@onready var fr_leg = $BaseArmature_001/Skeleton3D/IKFrontR
@onready var br_leg = $BaseArmature_001/Skeleton3D/IKBackR


func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= 9.8 * 4 * delta
	path_data = pather.find_position()
	var found_player = path_data[0]
	if found_player:
		closest_player_position = path_data[1]
	if state == "search":
		if !found_player:
			lerp_angle_look_at(closest_player_position, delta, 0.9)
			lerp_look_at(eye, closest_player_position, delta, 0.95)
			
			set_vel(move_speed, -transform.basis.z)
		elif found_player:
			lerp_angle_look_at(closest_player_position, delta, 0.9)
			lerp_look_at(eye, closest_player_position, delta, 0.95)
			
			set_vel(move_speed * 3.0, -transform.basis.z)
			
		#close to play start attack
		if found_player:
			var distance_to_player = closest_player_position.distance_to(global_position)
			if distance_to_player < distance_to_attack:
				if randi_range(0, 1) == 0:
					switch_state("attack")
				else:
					switch_state("flank")
	
	elif state == "attack":
		if action_timer.time_left > action_timer.wait_time - attack_charge_time:
			velocity.x *= 0.5
			velocity.z *= 0.5
			lerp_angle_look_at(closest_player_position, delta, 8.0)
			lerp_look_at(eye, closest_player_position, delta, 0.95)
		else:
			set_vel(move_speed * 3.0, -transform.basis.z)
		if action_timer.is_stopped():
			switch_state("search")
			
	elif state == "flank":
		lerp_angle_look_at(closest_player_position, delta, 8.0)
		lerp_look_at(eye, closest_player_position, delta, 0.95)
		set_vel(move_speed, flank_direction * transform.basis.x)
		if action_timer.is_stopped():
			switch_state("attack")
	move_and_slide()

func switch_state(change_state: String):
	if change_state == "search":
		state = change_state
	elif change_state == "attack":
		attack_charge_time = randf_range(0.75, 1.0)
		action_timer.wait_time = randf_range(2.0, 3.0)
		action_timer.start()
		state = change_state
	elif change_state == "flank":
		var rand_sign = -1 if randf() < 0.5 else 1
		flank_direction = rand_sign
		action_timer.wait_time = randf_range(3.0, 5.0)
		action_timer.start()
		state = change_state
	else:
		print("invalid state: " + change_state)
		
func set_vel(move_amount, direction):
	if is_on_floor():
		velocity = direction * move_amount

func get_angle_to_lookat_position(target_position):
	var direction: Vector3 = (target_position - position)
	var angle_yaw: float = -atan2(direction.z, direction.x) - PI/2.0
	var angle = abs(rotation.y - lerp_angle(rotation.y, angle_yaw, 1.0))
	return angle

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
	if not Vector3.UP.cross(target_position - global_transform.origin).is_zero_approx():
		thing_looking.look_at(target_position)
	var new_rotation: Vector3 = thing_looking.rotation
	thing_looking.rotation = old_rotation
	thing_looking.rotate_y(((new_rotation.y - old_rotation.y) * delta * rotation_speed))
	thing_looking.rotate_x(((new_rotation.x - old_rotation.x) * delta * rotation_speed))
	thing_looking.rotation.z = 0
