extends Node3D

var speed = 100.0
var damage = 5.0
var hit = false
var first_frame = 0

@onready var meshes = $Meshes
@onready var mesh = $Meshes/Base
@onready var laser_mesh = $Meshes/Laser
@onready var particles = $GPUParticles3D

func _ready():
	if speed > 500:
		laser_mesh.visible = true
		mesh.visible = false
	
	
func _setup(start_pos, look_to, config):
	speed = config[0]
	look_at_from_position(start_pos, look_to)
	rotate_x(config[1])
	rotate_y(config[2])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(global_transform.origin, global_transform.origin + global_transform.basis.z * (-speed * delta))
		var result = space_state.intersect_ray(query)
	#if Input.is_action_just_pressed("right_click"):
		#ray.target_position = Vector3(0, 0, -1.2 * speed * delta)
		if not result and not hit:
			position += transform.basis * Vector3(0, 0, -speed) * delta
		elif not hit:
			hit = true
			position = result.position
			meshes.visible = false
			particles.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
