extends Projectile

var projectile_speed = 10.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -projectile_speed) * delta
