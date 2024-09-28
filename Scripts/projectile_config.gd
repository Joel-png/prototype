extends Node3D
class_name ProjectileConfig

var speed = 100.0
var firerate = 1
var bullet_spread_hor = 1
var bullet_spread_ver = 1
var bloom_hor = 0
var bloom_ver = 0

func _init(_speed, _firerate, _bullet_spread_hor, _bullet_spread_ver, _bloom_hor, _bloom_ver):
	speed = _speed
	firerate = _firerate
	bullet_spread_hor = _bullet_spread_hor
	bullet_spread_ver = _bullet_spread_ver
	bloom_hor = _bloom_hor
	bloom_ver = _bloom_ver

func get_config():
	return [speed, firerate, bullet_spread_hor, bullet_spread_ver, bloom_hor, bloom_ver]
