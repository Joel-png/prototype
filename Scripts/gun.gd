extends Holdable
class_name Gun

var projectile_config: ProjectileConfig
var action_cooldown = 0
@onready var muzzle = $Muzzle

func _ready():
	projectile_config = ProjectileConfig.new(250, 0.1, 1, 1, 2, 2)
	

func action(delta):
	if Input.is_action_pressed("left_click") and action_cooldown <= 0:
		action_cooldown = projectile_config.firerate
		overseer.shoot(muzzle.global_position, muzzle.global_rotation, projectile_config.get_config())
	if action_cooldown > 0:
		action_cooldown -= delta
