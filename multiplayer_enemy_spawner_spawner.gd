extends MultiplayerSpawner

@onready var terrain = $"../../TerrainGeneration"

var scene: PackedScene = preload("res://Assets/Entity/Enemy/Spawner/enemy_spawner.tscn")

func _ready() -> void:
	spawn_function = spawn_enemy_spawner
	
func spawn_enemy_spawner(data):
	var enemy_spawner = scene.instantiate()
	enemy_spawner.set_multiplayer_authority(data)
	enemy_spawner.position.y = terrain.height_multiplier + 250 * 4
	return enemy_spawner
