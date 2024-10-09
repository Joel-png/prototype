extends Node3D

@onready var grass = $"../TerrainGeneration/GrassParticle"
@onready var grass2 = $"../TerrainGeneration/GrassParticle2"

func update_grass(pos):
	grass.position = pos
	grass2.position = pos
	grass.draw_pass_1.surface_get_material(0).set_shader_parameter("player_pos", pos)
