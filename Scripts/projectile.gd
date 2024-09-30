extends Node3D

var speed = 100.0
var damage = 5.0
var hit = false
var first_frame = true
var traveled_distance = 0

@onready var meshes = $Meshes
@onready var mesh = $Meshes/Base
@onready var laser_mesh = $Meshes/Laser
@onready var particles = $GPUParticles3D
@onready var y_pivot = $YPivot

func _ready():
	mesh.mesh.resource_local_to_scene = true
	var mesh_offset = speed/10
	mesh.mesh.size = Vector3(0.1, 0.1, mesh_offset)
	mesh.position.z = -mesh_offset/2
	
	
func _setup(start_pos, look_to, config, rot):
	speed = config[0]
	var bloom_x = config[1]
	var bloom_y = config[2]
	
	if rad_to_deg(abs(rot.x)) > 80:
		rotation = rot
		position = start_pos
	else:
		look_at_from_position(start_pos, look_to)
	rotate_object_local(Vector3.UP, bloom_y)
	rotate_object_local(Vector3.RIGHT, bloom_x)
	#y_pivot.rotate_object_local(Vector3.UP, bloom_y)
	#rotation.x = y_pivot.global_rotation.x
	#rotation.y = y_pivot.global_rotation.y
	
	
	

func get_x_y_angles_between_points(point_a, point_b):
	var direction = (point_b - point_a).normalized()
	var yaw = atan2(direction.x, direction.z)
	var pitch = asin(direction.y)
	return Vector2(pitch, yaw)

func _process(delta: float):
	if not first_frame:
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_transform.origin, global_transform.origin + global_transform.basis.z * (-speed * delta))
		var result = space_state.intersect_ray(query)
		if hit:
			meshes.visible = false
			particles.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
		#if Input.is_action_just_pressed("right_click"):
		#ray.target_position = Vector3(0, 0, -1.2 * speed * delta)
		if not result and not hit:
			position += transform.basis * Vector3(0, 0, -speed) * delta
			traveled_distance += speed * delta
			if traveled_distance > speed * 5:
				queue_free()
		elif not hit:
			hit = true
			position = result.position
	else:
		first_frame = false
