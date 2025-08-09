extends MultiplayerSpawner

@onready var terrain = $"../../TerrainGeneration"

var azathoth_scene: PackedScene = preload("res://Assets/Entity/Enemy/Azathoth/azathoth.tscn")

func _ready() -> void:
	spawn_function = spawn_azathoth
	
func spawn_azathoth(data):
	var azathoth = azathoth_scene.instantiate()
	azathoth.set_multiplayer_authority(data)
	azathoth.position.y = terrain.height_multiplier + 250 * 4
	azathoth.position.x = terrain.height_multiplier + 250 * 2
	azathoth.scale = Vector3(250, 250, 250)
	return azathoth
