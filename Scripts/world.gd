extends Node3D

var terrain_seed: int = 0
var fog: float = 0.0
@export var fog_curve: Curve
@onready var environment = $WorldEnvironment
@onready var terrain_generator = $TerrainGeneration
@onready var enemy_spawner_spawner = $MultiplayerSpawners/MultiplayerEnemySpawnerSpawner


func _ready() -> void:
	if is_multiplayer_authority():
		set_seed()
		print("Created world with seed: " + str(terrain_seed))
	terrain_generator.setup()
	if is_multiplayer_authority():
		pass#spawn_portal()

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

func spawn_portal():
	var portal = enemy_spawner_spawner.spawn(1)
	var world_size = terrain_generator.world_size
	var world_scale = terrain_generator.scale_multiplier
	var world_height = terrain_generator.height_multiplier * terrain_generator.height_multiplier
	portal.position = Vector3((randi_range(0, world_size) - world_size / 2) * world_scale, world_height, (randi_range(0, world_size) - world_size / 2) * world_scale)
