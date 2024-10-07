extends Node3D

@onready var grass = $"../TerrainGeneration/GrassParticle"

func update_grass(pos):
	grass.position = pos
