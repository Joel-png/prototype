extends Node3D

var parent_scale: float = 1.0
var base_scale: Vector3 = scale
var currently_attacking: bool = false
@onready var beam_mesh = $BeamMesh
@onready var inner_beam_mesh = $InnerBeamMesh
@onready var dish_mesh = $DishMesh
@onready var ray_cast = $RayCast3D
@onready var collision_shape = $Area3D/CollisionShape
@onready var hit_area = $Area3D

func _ready() -> void:
	hide()
	
func start_attack() -> void:
	currently_attacking = true
	show()
	
func stop_attack() -> void:
	currently_attacking = false
	hide()

func _process(_delta: float) -> void:
	if currently_attacking:
		set_length()
		if hit_area.has_overlapping_bodies():
			pass

func set_length() -> void:
	if ray_cast.is_colliding():
		var ray_cast_pos: Vector3 = ray_cast.get_collision_point()
		var distance_to_ray_cast: float = global_position.distance_to(ray_cast_pos)
		set_mesh_length(distance_to_ray_cast)
	else:
		set_mesh_length(ray_cast.target_position.z * base_scale.z * parent_scale)

func set_mesh_length(length: float):
	var extra_length_scale: float = 1.0
	var scaled_length: float = length / base_scale.z / parent_scale
	beam_mesh.scale.z = extra_length_scale * scaled_length
	inner_beam_mesh.scale.z = extra_length_scale * scaled_length
	collision_shape.shape.height = extra_length_scale * 2 * scaled_length
	collision_shape.position.z = extra_length_scale * scaled_length
