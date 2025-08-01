extends MultiplayerSpawner

@onready var terrain = $"../TerrainGeneration"

var scuttler_scene: PackedScene = preload("res://Assets/Entity/Enemy/Scuttler/scuttler.tscn")

func _ready() -> void:
	spawn_function = spawn_scuttler
	
func spawn_scuttler(data):
	var scutttler = scuttler_scene.instantiate()
	scutttler.set_multiplayer_authority(data)
	scutttler.position.y = terrain.height_multiplier * 8.0
	#scutttler.position.x = terrain.height_multiplier + 250 * 2
	#scutttler.scale = Vector3(1.0, 250, 250)
	return scutttler
