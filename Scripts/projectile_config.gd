extends Node3D
class_name ProjectileConfig

var speed: float = 100.0
var firerate: float = 1
var bullet_spread_hor: int = 1
var bullet_spread_ver: int = 1
var bloom_hor: float = 0
var bloom_ver: float = 0

func _init(_speed: float, _firerate: float, _bullet_spread_hor: int, _bullet_spread_ver: int, _bloom_hor: float, _bloom_ver: float) -> void:
	speed = _speed
	firerate = _firerate
	bullet_spread_hor = _bullet_spread_hor
	bullet_spread_ver = _bullet_spread_ver
	bloom_hor = _bloom_hor
	bloom_ver = _bloom_ver

func get_config():
	return [speed, firerate, bullet_spread_hor, bullet_spread_ver, bloom_hor, bloom_ver]
