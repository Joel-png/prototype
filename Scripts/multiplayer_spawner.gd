extends MultiplayerSpawner

var players = {}

@export var player_scene : PackedScene
@onready var terrain = $"../TerrainGeneration"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = spawn_player
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)
		
func spawn_player(data):
	var p = player_scene.instantiate()
	p.set_multiplayer_authority(data)
	players[data] = p
	p.position.y = terrain.height_multiplier
	return p
	
func remove_player(data) -> void:
	players[data].queue_free()
	players.erase(data)
