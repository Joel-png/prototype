extends CharacterBody3D

var move_speed: float = 20.0
var distance_to_attack: float = 50.0
var turn_speed: float = 1.0
var ground_offset: float = 1.5
var last_seen_player
var path_data = [false, Vector3(0, 0 ,0)]

var attacking: bool = false
var attack_charge_time: float = 2.0
var state: String = "search"

var flank_direction: int = 1
var closest_player_position = Vector3(0.0, 0.0, 0.0)
var found_player = false

@onready var armature = $BaseArmature_001
@onready var eye = $BaseArmature_001/Skeleton3D/FullBody/Eye
@onready var pather = $Pather

@onready var action_timer = $ActionTimer

@onready var fl_leg = $BaseArmature_001/Skeleton3D/IKFrontL
@onready var bl_leg = $BaseArmature_001/Skeleton3D/IKBackL
@onready var fr_leg = $BaseArmature_001/Skeleton3D/IKFrontR
@onready var br_leg = $BaseArmature_001/Skeleton3D/IKBackR

var target_position: Vector3 = Vector3.ZERO
var counter = randf_range(0, 1.0)
var update_frequency = 1.0
var rotation_speed: float = 0.0
var total_time_alive = 0
var lerp_speed = 3.0

func _process(delta: float) -> void:
	total_time_alive += delta
	if is_multiplayer_authority():
		path_data = pather.find_position()
		found_player = path_data[0]
		if found_player:
			closest_player_position = path_data[1]
		if not is_on_floor():
			velocity.y -= 9.8 * 4 * delta
		counter -= delta
		if counter <= 0.0:
			#sync_state.rpc(position, rotation, closest_player_position)
			_process_states(delta)
			counter += update_frequency
	
	
	lerp_look_at(eye, closest_player_position + Vector3(0, 0.5, 0), delta, 0.99)
	
	if is_multiplayer_authority():
		lerp_angle_look_at(closest_player_position, delta, rotation_speed)
		move_and_slide()
		target_position = global_position
	else:
		if is_inside_tree():
			global_position = global_position.lerp(target_position, delta * lerp_speed)

@rpc("any_peer", "call_remote", "unreliable_ordered")
func sync_state(pos: Vector3, rot: Vector3, closest_player: Vector3):
	#if total_time_alive > 20:
		position = pos
		rotation = rot
		closest_player_position = closest_player

func _process_states(_delta: float) -> void:
	match state:
		"search":
			rotation_speed = 0.9
			if !found_player:
				set_vel(move_speed, -transform.basis.z)
			elif found_player:
				var distance_to_player = closest_player_position.distance_to(global_position)
				set_vel(move_speed * (3.0 + max(0.0, distance_to_player / 100.0)), -transform.basis.z)
				
				#close to play start attack
				if distance_to_player < distance_to_attack:
					if randi_range(0, 1) == 0:
						switch_state("attack")
					else:
						switch_state("flank")
		"attack":
			if action_timer.time_left > action_timer.wait_time - attack_charge_time:
				velocity.x *= 0.0
				velocity.z *= 0.0
				rotation_speed = 8.0
			else:
				rotation_speed = 0.0
				set_vel(move_speed * 3.0, -transform.basis.z)
			if action_timer.is_stopped():
				switch_state("search")
				
		"flank":
			rotation_speed = 8.0
			set_vel(move_speed, flank_direction * transform.basis.x)
			if action_timer.is_stopped():
				switch_state("attack")


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
		var current_y_vel = velocity.y
		velocity = direction * move_amount * 1.0
		velocity.y += current_y_vel

func get_angle_to_lookat_position(look_at_position):
	var direction: Vector3 = (look_at_position - position)
	var angle_yaw: float = -atan2(direction.z, direction.x) - PI/2.0
	var angle = abs(rotation.y - lerp_angle(rotation.y, angle_yaw, 1.0))
	return angle

func lerp_angle_look_at(look_at_position: Vector3, delta: float, _rotation_speed: float) -> void:
	var direction: Vector3 = (look_at_position - position)
	#var direction_x_z: float = pow(pow(direction.x, 2) + pow(direction.z, 2), 0.5)
	#var angle_pitch: float = -atan2(direction_x_z, direction.y) + PI/2.0
	var angle_yaw: float = -atan2(direction.z, direction.x) - PI/2.0
	var angle = abs(rotation.y - lerp_angle(rotation.y, angle_yaw, 1.0))
	if angle > 0.5 and state != "attack":
		_rotation_speed *= 4.0
		velocity.x *= 0.1
		velocity.z *= 0.1
	rotation.y = lerp_angle(rotation.y, angle_yaw, _rotation_speed * delta)

func lerp_look_at(thing_looking, look_at_position: Vector3, _delta: float, _rotation_speed: float) -> void:
	#var old_rotation: Vector3 = thing_looking.rotation
	var dir = (look_at_position - global_transform.origin).normalized()
	var up = Vector3.UP

	# If dir and up are too close, pick a different up vector
	if abs(dir.dot(up)) > 0.999:
		up = Vector3.FORWARD  # or Vector3.RIGHT, something not parallel
	thing_looking.look_at(look_at_position, up)
	#var new_rotation: Vector3 = thing_looking.rotation
	#thing_looking.rotation = old_rotation
	#thing_looking.rotate_y(((new_rotation.y - old_rotation.y) * delta * rotation_speed))
	#thing_looking.rotate_x(((new_rotation.x - old_rotation.x) * delta * rotation_speed))
	#thing_looking.rotation.z = 0
