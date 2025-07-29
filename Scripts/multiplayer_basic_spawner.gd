extends MultiplayerSpawner

@export var scene: PackedScene

func _ready() -> void:
	spawn_function = spawn_scene
	
func spawn_scene(data):
	var new_scene = scene.instantiate()
	new_scene.set_multiplayer_authority(data)
	return new_scene
