extends CharacterBody3D
class_name Projectile

var max_projectile_speed = 1000.0
var initial_projectile_speed = 100.0
var projectile_speed_acc = 500.0
var projectile_speed = 0.0

var multiplayer_auth
var damage
var projectile_count
var equipped_fish

func setup(_multiplayer_authority, _pos, _rot, _damage, _projectile_count, _equipped_fish):
	multiplayer_auth = _multiplayer_authority
	position = _pos
	look_at_from_position(_pos, _rot)
	damage = _damage
	projectile_count = _projectile_count
	equipped_fish = _equipped_fish
	projectile_speed = initial_projectile_speed

func calc_projectile_speed(delta):
	if projectile_speed < max_projectile_speed:
		projectile_speed += projectile_speed_acc * delta
		if projectile_speed > max_projectile_speed:
			projectile_speed = max_projectile_speed

func get_player_by_authority(authority_id: int) -> Node:
	for player in get_tree().get_nodes_in_group("Player"):
		if player.get_multiplayer_authority() == authority_id:
			return player
	return null
