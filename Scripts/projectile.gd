extends Node3D
class_name Projectile

var multiplayer_authority
var damage
var projectile_count
var equipped_fish

func setup(_multiplayer_authority, _pos, _rot, _damage, _projectile_count, _equipped_fish):
	multiplayer_authority = _multiplayer_authority
	position = _pos
	rotation = _rot
	damage = _damage
	projectile_count = _projectile_count
	equipped_fish = _equipped_fish
