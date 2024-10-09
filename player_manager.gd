extends Node3D

@onready var grass_clump = $"../TerrainGeneration/GrassClumpParticle"
@onready var grass_spot = $"../TerrainGeneration/GrassSpotParticle"
@onready var rock_small = $"../TerrainGeneration/RockSmallParticle"
@onready var shrubs = $"../TerrainGeneration/ShrubParticle"

func update_grass(pos):
	grass_clump.position = pos
	grass_spot.position = pos
	rock_small.position = pos
	shrubs.position = pos
