extends Node3D

var parent_scale: float = 1.0
var base_scale = scale
@onready var beam_mesh = $BeamMesh
@onready var inner_beam_mesh = $InnerBeamMesh
@onready var dish_mesh = $DishMesh
@onready var ray_cast = $RayCast3D

func set_length() -> void:
	if ray_cast.is_colliding():
		var ray_cast_pos: Vector3 = ray_cast.get_collision_point()
		var distance_to_ray_cast: float = global_position.distance_to(ray_cast_pos)
		set_mesh_length(distance_to_ray_cast)
	else:
		set_mesh_length(ray_cast.target_position.z)
		

func set_mesh_length(length: float):
	beam_mesh.scale.z = 2 * length / base_scale.z / parent_scale
	inner_beam_mesh.scale.z = 2 * length/ base_scale.z / parent_scale
