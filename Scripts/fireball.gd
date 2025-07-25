extends Projectile



func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if get_slide_collision_count() > 0:
		print("collided")
		var player = get_player_by_authority(multiplayer_auth)
		if player.is_player:
			player.position = position
		self.queue_free()
	calc_projectile_speed(delta)
	velocity = transform.basis * Vector3(0, 0, -projectile_speed)
	move_and_slide()
	
	
