extends Holdable
class_name Shotgun

const SHOTGUN_FORCE = 50.0
const SHOTGUN_FORCE_DIRECTION = Vector3(0, 0, 1)
var projectile_spawn

func _init(new_overseer):
	scene_to_set = "res://shotgun.tscn"
	super._init(new_overseer)
	if scene:
		scene.visible = false
		projectile_spawn = scene.get_node("ProjectileSpawn")
	else:
		queue_free()
	
func action():
	if Input.is_action_just_pressed("left_click"):
		overseer.shoot(projectile_spawn.global_position, projectile_spawn.global_rotation)
		var shotgun_direction = overseer.transform.basis * overseer.camera.transform.basis * SHOTGUN_FORCE_DIRECTION * SHOTGUN_FORCE
		overseer.velocity += shotgun_direction
