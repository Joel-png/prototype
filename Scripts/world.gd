extends Node3D

var terrain_seed: int = 0
var fog: float = 0.0
@export var fog_curve: Curve
@onready var environment = $WorldEnvironment
@onready var terrain_generator = $TerrainGeneration
@onready var azathoth_spawner = $MultiplayerAzathothSpawner
@onready var scuttler_spawner = $MultiplayerScuttlerSpawner

func _ready() -> void:
	if is_multiplayer_authority():
		set_seed()
		print("Created world with seed: " + str(terrain_seed))
	terrain_generator.setup()
	if is_multiplayer_authority():
		pass
		#azathoth_spawner.spawn(1)
		scuttler_spawner.spawn(1)

func set_seed() -> void:
	terrain_seed = randi_range(0, 1000)

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		if Input.is_action_pressed("right_arrow"):
			fog -= 0.001
		if Input.is_action_pressed("left_arrow"):
			fog += 0.001
		fog = clamp(fog, 0.01, 0.99)
	environment.get_environment().volumetric_fog_density = fog_curve.sample(fog)
	
