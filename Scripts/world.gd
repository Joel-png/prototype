extends Node3D

var terrain_seed: int = 0
@onready var terrain_generator = $TerrainGeneration
@onready var azathoth_spawner = $MultiplayerAzathothSpawner

func _ready() -> void:
	if is_multiplayer_authority():
		set_seed()
		print("Created world with seed: " + str(terrain_seed))
	terrain_generator.setup()
	if is_multiplayer_authority():
		azathoth_spawner.spawn(1)

func set_seed() -> void:
	terrain_seed = randi_range(0, 1000)
