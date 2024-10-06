extends Node3D

var terrain_seed = 0
@onready var terrain_generator = $TerrainGeneration

func _ready():
	if is_multiplayer_authority():
		set_seed()
		print(str(terrain_seed) + " world")
	terrain_generator.setup()

func set_seed():
	terrain_seed = randi_range(0, 10)
	terrain_seed = 0
	print(str(terrain_seed) + " set world seed")
