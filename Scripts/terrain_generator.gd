class_name TerrainGeneration
extends Node3D

var mesh : MeshInstance3D
var size_depth : int = 100
var size_width : int = 100
var mesh_resolution : int = 2
var height_multiplier = 80
var scale_multiplier = 20

@export var noise : FastNoiseLite
var terrain_seed = 0

@onready var world = $".."

func setup():
	terrain_seed = world.terrain_seed
	print(str(terrain_seed) + "is seed")
	generate()

func generate():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size_width, size_depth)
	plane_mesh.subdivide_depth = size_depth * mesh_resolution
	plane_mesh.subdivide_width = size_width * mesh_resolution
	plane_mesh.material = preload("res://Assets/terrain_material.tres")
	
	var surface = SurfaceTool.new()
	var data = MeshDataTool.new()
	surface.create_from(plane_mesh, 0)
	
	var array_plane = surface.commit()
	data.create_from_surface(array_plane, 0)
	
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		var y = get_noise_y(vertex.x, vertex.z)
		
		vertex.y = y * height_multiplier
		vertex.x = vertex.x * scale_multiplier
		vertex.z = vertex.z * scale_multiplier
		
		data.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	data.commit_to_surface(array_plane)
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface.create_from(array_plane, 0)
	surface.generate_normals()
	
	mesh = MeshInstance3D.new()
	mesh.mesh = surface.commit()
	mesh.create_trimesh_collision()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	add_child(mesh)
	

func get_noise_y(x, z):
	var value = noise.get_noise_2d(x, z)
	return value
