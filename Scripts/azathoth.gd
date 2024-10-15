extends CharacterBody3D

var movement_direction: Vector3 = Vector3(0, 0, -1)
var movement_amount: float = 20.0

@onready var body = $Body
@onready var eye = $Body/Eye
@onready var eye_mesh = $Body/Eye/EyeballMesh
@onready var detection_area = $Body/DetectionArea
@onready var idle_look_at = $IdleLookAt
@onready var idle_look_at_animation = $IdleLookAt/IdleLookAtAnimation

@onready var timer_movement = $TimerMovement
@onready var timer_attack = $TimerAttack

func _process(delta: float) -> void:
	if detection_area.has_overlapping_bodies():
		var detected_players: Array = detection_area.get_overlapping_bodies()
		var closests_player_index: int = get_closest_player_index(detected_players)
		var closets_player_position: Vector3 = detected_players[closests_player_index].position
		lerp_angle_look_at(body, closets_player_position, delta, 0.5)
		lerp_look_at(eye, closets_player_position, delta, 2.0)
	else:
		body.rotation.x = lerp_angle(body.rotation.x, 0, 0.5 * delta)
		lerp_look_at(eye, idle_look_at.global_position, delta, 2.0)
		if not idle_look_at_animation.is_playing():
			idle_look_at_animation.play("idle_look_at")
	velocity += movement_direction * delta
	velocity.x = clamp(velocity.x, -abs(movement_direction.x), abs(movement_direction.x))
	velocity.z = clamp(velocity.z, -abs(movement_direction.z), abs(movement_direction.z))
	velocity *= 0.99
	position += velocity * delta

func calc_movement() -> void:
	var direction_type = randi_range(-1, 1)
	var forward_direction: Vector3 = -global_transform.basis.z.normalized()
	var left_direction: Vector3 = global_transform.basis.x.normalized()
	var total_direction = forward_direction + left_direction * direction_type
	movement_direction = total_direction * movement_amount

func _on_timer_movement_timeout() -> void:
	calc_movement()
	
func lerp_angle_look_at(thing_looking, target_position: Vector3, delta: float, rotation_speed: float) -> void:
	var direction: Vector3 = (target_position - position)
	var direction_x_z: float = pow(pow(direction.x, 2) + pow(direction.z, 2), 0.5)
	var angle_pitch: float = -atan2(direction_x_z, direction.y) + PI/2.0
	var angle_yaw: float = -atan2(direction.z, direction.x) - PI/2.0
	
	rotation.y = lerp_angle(rotation.y, angle_yaw, rotation_speed * delta)
	thing_looking.rotation.x = lerp_angle(thing_looking.rotation.x, angle_pitch, rotation_speed * delta)

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
