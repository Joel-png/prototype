extends Node3D

var PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()
var lobby_id = 0
var peer = SteamMultiplayerPeer.new()

@onready var multiplayer_spawner = $MultiplayerSpawner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer_spawner.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(on_lobby_match_list)
	open_lobby_list()

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a
	
func _on_host_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	var world = multiplayer_spawner.spawn("res://world.tscn")
	world.set_multiplayer_authority(1)
	hide_menu()
	
func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	hide_menu()
	
func _on_lobby_created(_connect, id):
	if _connect:
		lobby_id = id
		#Steam.setLobbyData(lobby_id, "name", str("Joel test Lobby" + Steam.getPersonaName()))
		Steam.setLobbyData(lobby_id, "name", str("Joel test lobby"))
		Steam.setLobbyJoinable(lobby_id, true)
		print(lobby_id)

func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.addRequestLobbyListStringFilter("name", "Joel test lobby", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()
	
func on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby, "name")
		var mem_count = Steam.getNumLobbyMembers(lobby)
		
		var but = Button.new()
		but.set_text(str(lobby_name, " | Player Count: ", mem_count))
		but.set_size(Vector2(100, 5))
		but.connect("pressed", Callable(self, "join_lobby").bind(lobby))
		
		$LobbyContainer/Lobbies.add_child(but)


func _on_refresh_pressed():
	if $LobbyContainer/Lobbies.get_child_count() > 0:
		for n in $LobbyContainer/Lobbies.get_children():
			n.queue_free()
	open_lobby_list()


func _on_host_local_pressed():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	var world = multiplayer_spawner.spawn("res://world.tscn")
	world.set_multiplayer_authority(1)
	hide_menu()


func _on_join_local_pressed() -> void:
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	hide_menu()
	
func hide_menu():
	$Host.hide()
	$Refresh.hide()
	$LobbyContainer/Lobbies.hide()
	$"Host local".hide()
	$"Join local".hide()
