extends Node3D

var speed: float = 100.0
var damage: float = 5.0
var size
var hit: bool = false
var first_frame: bool = true
var traveled_distance: float = 0
var low_mode: bool = false
var particle_amount_ratio: int = 1

@onready var meshes = $Meshes
@onready var mesh = $Meshes/Base
@onready var laser_mesh = $Meshes/Laser
@onready var death_sparks = $DeathSparks
@onready var trail_particles = $TrailParticle
@onready var y_pivot = $YPivot
@onready var ray_cast = $RayCast3D

func _ready() -> void:
	mesh.mesh.resource_local_to_scene = true
	trail_particles.draw_pass_1.resource_local_to_scene = true

func _setup(start_pos: Vector3, look_to: Vector3, config, rot: Vector3) -> void:
	if get_parent_node_3d().get_child_count() > 1000:
		low_mode = true
	speed = config[0]
	size = speed/100.0
	mesh.mesh.size = Vector3(0.1, 0.1, size)
	mesh.position.z = -size/2
	death_sparks.position.z = -size
	var bloom_x: float = config[1]
	var bloom_y: float = config[2]
	
	if rad_to_deg(abs(rot.x)) > 80:
		rotation = rot
		position = start_pos
	else:
		look_at_from_position(start_pos, look_to)
	rotate_object_local(Vector3.UP, bloom_y)
	rotate_object_local(Vector3.RIGHT, bloom_x)
	
	var delta: float = get_process_delta_time()
	var result = update_ray_cast(delta)
	if result:
		collide(result)
		hit = true
	else:
		var mesh_offset: float = max(speed * delta, size)
		trail_particles.process_material.emission_box_extents.z = mesh_offset
		trail_particles.process_material.emission_shape_offset.z = -mesh_offset
	trail_particles.fixed_fps = Engine.get_frames_per_second()
	particle_amount_ratio = min(speed/10000.0, 1)
	#trail_particles.amount_ratio = particle_amount_ratio
	#print(particle_amount_ratio)

func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("right_click"):
		
		if hit:
			trail_particles.emitting = false
			death_sparks.emitting = true
			meshes.visible = false
			if not low_mode:
				await get_tree().create_timer(1.0).timeout
			kill()
		
		var result = update_ray_cast(delta)
		#ray.target_position = Vector3(0, 0, -1.2 * speed * delta)
		if not result:
			position += transform.basis * Vector3(0, 0, -speed) * delta
			traveled_distance += speed * delta
			if traveled_distance > speed * 5:
				kill()
			
		elif not hit:
			hit = true
			collide(result)

func collide(result) -> void:
	var mesh_offset: float = position.distance_to(result)
	trail_particles.process_material.emission_box_extents.z = mesh_offset / 4
	if mesh_offset < size:
		mesh.mesh.size = Vector3(0.1, 0.1, mesh_offset)
		mesh.position.z = -mesh_offset/2 - (size - mesh_offset)
		trail_particles.emitting = false
	else:
		trail_particles.process_material.emission_shape_offset.z = -mesh_offset / 2
	position = result + global_transform.basis.z * size

func update_ray_cast(delta) -> Vector3:
	var ray_cast_length: float = Vector3(0,0,0).distance_to(global_transform.basis.z * ((-speed * delta) - size))
	ray_cast.target_position.z = -ray_cast_length
	ray_cast.force_raycast_update()
	return ray_cast.get_collision_point()

func kill() -> void:
	queue_free()
