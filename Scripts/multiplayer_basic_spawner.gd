extends MultiplayerSpawner

@export var scene: PackedScene
@export var scale_amount: Vector3 = Vector3(1.0, 1.0, 1.0)

func _ready() -> void:
	spawn_function = spawn_scene

func spawn_with_parameters(_position, _scale, auth):
	var new_scene = spawn(auth)
	new_scene.position = _position
	new_scene.scale = _scale
	
func spawn_scene(data):
	var new_scene = scene.instantiate()
	new_scene.set_multiplayer_authority(data)
	return new_scene
