extends MultiplayerSpawner

var players = {}

@export var player_scene : PackedScene
@onready var max_height = $"../TerrainGeneration"
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawn_player
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(remove_player)
		
func spawn_player(data):
	var p = player_scene.instantiate()
	p.set_multiplayer_authority(data)
	#print(data)
	players[data] = p
	p.position.y = max_height.height_multiplier
	#players[data].collision_mask = players.size()
	return p
	
func remove_player(data):
	players[data].queue_free()
	players.erase(data)
