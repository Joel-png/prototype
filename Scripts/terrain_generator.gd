class_name TerrainGeneration
extends Node3D

var mesh : MeshInstance3D
var world_size : int = 50
var mesh_resolution : int = 1
var height_multiplier = 400
var scale_multiplier = 50
var grass_scale = 5


@export var noise_texture : NoiseTexture2D
var terrain_seed = 0
var image: Image

@onready var world = $".."
@onready var grass = $GrassParticle

func setup():
	terrain_seed = world.terrain_seed
	noise_texture.width = world_size + 2
	noise_texture.height = world_size + 2
	noise_texture.noise.seed = terrain_seed
	print(str(terrain_seed) + "is seed")
	var shader_material = grass.process_material
	shader_material.set_shader_parameter("map_heightmap", noise_texture)
	
	var heightmap_scale = world_size + 2
	var heightmap_size = Vector2(heightmap_scale, heightmap_scale)
	var rows = (heightmap_scale - 1) * grass_scale
	grass.amount = rows*rows
	shader_material.set_shader_parameter("instance_rows", rows)
	shader_material.set_shader_parameter("map_heightmap_size", heightmap_size)
	shader_material.set_shader_parameter("__terrain_amplitude", height_multiplier)
	shader_material.set_shader_parameter("size_difference_of_world", scale_multiplier)
	await noise_texture.changed
	generate()

func generate():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(world_size + 1, world_size + 1)
	plane_mesh.subdivide_depth = world_size * mesh_resolution
	plane_mesh.subdivide_width = world_size * mesh_resolution
	plane_mesh.material = preload("res://Assets/ground_material.tres")
	
	var surface = SurfaceTool.new()
	var data = MeshDataTool.new()
	surface.create_from(plane_mesh, 0)
	
	var array_plane = surface.commit()
	data.create_from_surface(array_plane, 0)
	
	image = noise_texture.get_image()
	
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		var y = get_noise_y(vertex.x + floor(world_size / 2.0) + 1, vertex.z + floor(world_size / 2.0) + 1)
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
	var value = image.get_pixel(x, z).r
	return value
