extends MultiplayerSpawner

@onready var scene = preload("res://instrument.tscn")

func _ready() -> void:
	spawn_function = spawn_item
	
func spawn_item(data):
	var item = scene.instantiate()
	item.set_multiplayer_authority(data)
	return item
