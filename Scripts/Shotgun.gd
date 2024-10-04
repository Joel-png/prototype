extends Holdable
class_name Shotgun

const SHOTGUN_FORCE = 50.0
const SHOTGUN_FORCE_DIRECTION = Vector3(0, 0, 1)

var projectile_config: ProjectileConfig
var action_cooldown = 0

@onready var muzzle = $Muzzle

func _ready():
	projectile_config = ProjectileConfig.new(350, 0.5, 5, 3, 10, 7)

func action(delta):
	if Input.is_action_just_pressed("left_click") and action_cooldown <= 0:
		action_cooldown = projectile_config.firerate
		overseer.shoot(muzzle.global_position, muzzle.global_rotation, projectile_config.get_config())
		if not overseer.is_on_floor():
			var shotgun_direction = overseer.transform.basis * overseer.camera.transform.basis * SHOTGUN_FORCE_DIRECTION * SHOTGUN_FORCE
			overseer.velocity += shotgun_direction
	if action_cooldown > 0:
		action_cooldown -= delta
