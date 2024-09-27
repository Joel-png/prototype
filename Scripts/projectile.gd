extends Node3D

var speed = 100.0
var damage = 5.0
var hit = false
var first_frame = 0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

func _ready():
	pass
	#ray.target_position = Vector3(0, 0, -1 * speed * get_physics_process_delta_time())
	
func _setup(start_pos, angle):
	position = start_pos
	rotation = angle
	
	

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
			mesh.visible = false
			particles.emitting = true
			await get_tree().create_timer(1.0).timeout
			queue_free()
