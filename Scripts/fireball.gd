extends Projectile

var projectile_speed = 10000.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if get_slide_collision_count() > 0:
		print("collided")
		self.queue_free()
	velocity = transform.basis * Vector3(0, 0, -projectile_speed)
	move_and_slide()
	
	
