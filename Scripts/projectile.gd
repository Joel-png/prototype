extends Node3D

var speed = 100.0
var damage = 5.0
var size
var hit = false
var first_frame = true
var traveled_distance = 0
var low_mode = false
var particle_amount_per_second = 1000

@onready var meshes = $Meshes
@onready var mesh = $Meshes/Base
@onready var laser_mesh = $Meshes/Laser
@onready var death_sparks = $DeathSparks
@onready var trail_particles = $TrailParticle
@onready var y_pivot = $YPivot
@onready var ray_cast = $RayCast3D

func _ready():
	mesh.mesh.resource_local_to_scene = true
	trail_particles.draw_pass_1.resource_local_to_scene = true

func _setup(start_pos, look_to, config, rot):
	if get_parent_node_3d().get_child_count() > 1000:
		low_mode = true
	speed = config[0]
	size = speed/100.0
	mesh.mesh.size = Vector3(0.1, 0.1, size)
	mesh.position.z = -size/2
	death_sparks.position.z = -size
	var bloom_x = config[1]
	var bloom_y = config[2]
	
	if rad_to_deg(abs(rot.x)) > 80:
		rotation = rot
		position = start_pos
	else:
		look_at_from_position(start_pos, look_to)
	rotate_object_local(Vector3.UP, bloom_y)
	rotate_object_local(Vector3.RIGHT, bloom_x)
	
	var delta = get_process_delta_time()
	var result = update_ray_cast(delta)
	if result:
		collide(result)
		hit = true
	else:
		var mesh_offset = max(speed * delta, size)
		trail_particles.process_material.emission_box_extents.z = mesh_offset / 2
		trail_particles.process_material.emission_shape_offset.z = -mesh_offset / 2
	trail_particles.fixed_fps = Engine.get_frames_per_second()

func _process(delta: float):
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

func collide(result):
	var mesh_offset = position.distance_to(result)
	trail_particles.process_material.emission_box_extents.z = mesh_offset / 4
	if mesh_offset < size:
		mesh.mesh.size = Vector3(0.1, 0.1, mesh_offset)
		mesh.position.z = -mesh_offset/2 - (size - mesh_offset)
		trail_particles.emitting = false
	else:
		trail_particles.process_material.emission_shape_offset.z = -mesh_offset / 2
	position = result + global_transform.basis.z * size

func update_ray_cast(delta):
	var ray_cast_length = Vector3(0,0,0).distance_to(global_transform.basis.z * ((-speed * delta) - size))
	ray_cast.target_position.z = -ray_cast_length
	ray_cast.force_raycast_update()
	return ray_cast.get_collision_point()

func kill():
	queue_free()
