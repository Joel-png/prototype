extends Holdable
class_name Gun

#const SHOTGUN_FORCE = 50.0
#const SHOTGUN_FORCE_DIRECTION = Vector3(0, 0, 1)
var projectile_spawn
var projectile_config: ProjectileConfig
var action_cooldown = 0

func _init(new_overseer):
	scene_to_set = "res://gun.tscn"
	super._init(new_overseer)
	if scene:
		scene.visible = false
		projectile_spawn = scene.get_node("ProjectileSpawn")
		projectile_config = ProjectileConfig.new(250, 0.05, 2, 2, 2, 2)
	else:
		queue_free()
	

func action(delta):
	if Input.is_action_pressed("left_click") and action_cooldown <= 0:
		action_cooldown = projectile_config.firerate
		overseer.shoot(projectile_spawn.global_position, projectile_spawn.global_rotation, projectile_config.get_config())
		#var shotgun_direction = overseer.transform.basis * overseer.camera.transform.basis * SHOTGUN_FORCE_DIRECTION * SHOTGUN_FORCE
		#overseer.velocity += shotgun_direction
	if action_cooldown > 0:
		action_cooldown -= delta
