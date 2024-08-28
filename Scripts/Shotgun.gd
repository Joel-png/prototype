extends Holdable
class_name Shotgun

const SHOTGUN_FORCE = 35.0
const SHOTGUN_FORCE_DIRECTION = Vector3(0, 0, 1)

func _init(new_overseer):
	super._init(new_overseer)
	
	scene = load("res://shotgun.tscn").instantiate()
	scene.visible = false
	
func action():
	if Input.is_action_just_pressed("left_click"):
		var shotgun_direction = overseer.transform.basis * overseer.camera.transform.basis * SHOTGUN_FORCE_DIRECTION * SHOTGUN_FORCE
		overseer.velocity += shotgun_direction
