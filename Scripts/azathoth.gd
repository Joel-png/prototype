extends CharacterBody3D

@onready var eye = $Eye
@onready var eye_mesh = $Eye/EyeballMesh
@onready var detection_area = $DetectionArea

func _process(delta):
	if detection_area.has_overlapping_bodies():
		print(get_closest_player())
	
	
func get_closest_player():
	var overlapping_bodies = detection_area.get_overlapping_bodies()
	return overlapping_bodies.size()
