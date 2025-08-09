extends MultiplayerSpawner

@onready var terrain = $"../../TerrainGeneration"

var scuttler_scene: PackedScene = preload("res://Assets/Entity/Enemy/Scuttler/scuttler.tscn")

func _ready() -> void:
	spawn_function = spawn_scuttler
	
func spawn_scuttler(data):
	var scutttler = scuttler_scene.instantiate()
	scutttler.set_multiplayer_authority(data)
	return scutttler
