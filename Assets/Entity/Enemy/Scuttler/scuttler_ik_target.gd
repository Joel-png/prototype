extends Marker3D

@export var step_target: Node3D
@export var step_distance: float = 1.5

@export var adjacent_target: Node3D
@export var opposite_target: Node3D

var is_stepping: bool = false
var adjacent_is_stepping: bool = false
var adjacent_distance: float = 0.0
var distance_from: float = 0.0

func _process(delta: float) -> void:
	if adjacent_target:
		adjacent_is_stepping = adjacent_target.is_stepping
		adjacent_distance = adjacent_target.distance_from
	else:
		adjacent_is_stepping = false
	distance_from = abs(global_position.distance_to(step_target.global_position))
	if not is_stepping and not adjacent_is_stepping and distance_from > step_distance and distance_from > adjacent_distance:
		step()
		if opposite_target:
			opposite_target.step()

func step():
	var target_pos = step_target.global_position
	var half_way = (global_position + step_target.global_position) / 2
	is_stepping = true
	
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + owner.basis.y, 0.1)
	t.tween_property(self, "global_position", target_pos, 0.1)
	t.tween_callback(func(): is_stepping = false)
