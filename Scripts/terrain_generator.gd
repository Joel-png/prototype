class_name TerrainGeneration
extends Node3D

var mesh : MeshInstance3D
var world_size : int = 29
var mesh_resolution : int = 1
var scale_multiplier = 30
var height_multiplier = 3 * scale_multiplier

var grass_scale = 7


@export var noise_texture : NoiseTexture2D
var terrain_seed = 0
var image: Image

@onready var world = $".."
@onready var grass_clumps = $GrassClumpParticle
@onready var grass_spots = $GrassSpotParticle
@onready var rocks_small = $RockSmallParticle
@onready var shrubs = $ShrubParticle

func setup():
	terrain_seed = world.terrain_seed
	noise_texture.width = world_size + 2
	noise_texture.height = world_size + 2
	noise_texture.noise.seed = terrain_seed
	print(str(terrain_seed) + "is seed")
	var grass_clumps_sm = grass_clumps.process_material
	var grass_spots_sm = grass_spots.process_material
	var rock_small_sm = rocks_small.process_material
	var shrubs_sm = shrubs.process_material
	
	await noise_texture.changed
	#image = noise_texture.get_image()
	image = modify_noise(noise_texture)
	
	var height_texture = ImageTexture.new()
	height_texture.set_image(image)
	
	var normal_map = ImageTexture.new()
	var normal_image = Image.new()
	normal_image.copy_from(image)
	normal_image.bump_map_to_normal_map(height_multiplier)
	
	normal_map.set_image(normal_image)
	
	var heightmap_scale = world_size + 2
	var heightmap_size = Vector2(heightmap_scale, heightmap_scale)
	var rows = 100 * grass_scale
	var grass_base_spacing = 0.25 # spacing at which is considered the default render distance for other spacings
	var grass_clumps_spacing = 0.25
	var grass_spots_spacing = 1.0
	var rocks_small_spacing = 4.0
	var shrubs_spacing = 10.0
	var clumps_rows = floor(rows * (grass_base_spacing / grass_clumps_spacing))
	var spots_rows = floor(rows * (grass_base_spacing / grass_spots_spacing))
	var rocks_small_rows = floor(rows * (grass_base_spacing / rocks_small_spacing))
	var shrubs_rows = floor(rows * (grass_base_spacing / shrubs_spacing))
	print(rocks_small_rows)
	grass_clumps.amount = clumps_rows*clumps_rows
	grass_spots.amount = spots_rows*spots_rows
	rocks_small.amount = rocks_small_rows*rocks_small_rows
	shrubs.amount = shrubs_rows*shrubs_rows
	
	setup_shader(grass_clumps_sm, height_texture, normal_map, grass_clumps_spacing, clumps_rows, heightmap_size)
	setup_shader(grass_spots_sm, height_texture, normal_map, grass_spots_spacing, spots_rows, heightmap_size)
	setup_shader(rock_small_sm, height_texture, normal_map, rocks_small_spacing, rocks_small_rows, heightmap_size)
	setup_shader(shrubs_sm, height_texture, normal_map, shrubs_spacing, shrubs_rows, heightmap_size)
	
	generate()

func generate():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(world_size + 1, world_size + 1)
	plane_mesh.subdivide_depth = world_size * mesh_resolution
	plane_mesh.subdivide_width = world_size * mesh_resolution
	var material = preload("res://Assets/Ground/ground_material.tres")
	material.set_shader_parameter("uv_scale", world_size * scale_multiplier / 4.0)
	plane_mesh.material = material
	
	var surface = SurfaceTool.new()
	var data = MeshDataTool.new()
	surface.create_from(plane_mesh, 0)
	
	var array_plane = surface.commit()
	data.create_from_surface(array_plane, 0)
	
	
	
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		var y = get_noise_y(vertex.x + floor(world_size / 2.0) + 1, vertex.z + floor(world_size / 2.0) + 1)
		vertex.y = y * height_multiplier
		vertex.x = vertex.x * scale_multiplier
		vertex.z = vertex.z * scale_multiplier
		
		data.set_vertex(i, vertex)
	
	array_plane.clear_surfaces()
	data.commit_to_surface(array_plane)
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	surface.create_from(array_plane, 0)
	surface.generate_normals()
	
	mesh = MeshInstance3D.new()
	mesh.mesh = surface.commit()
	mesh.create_trimesh_collision()
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	
	add_child(mesh)
	

func setup_shader(material, height_texture, normal_map, spacing, rows, heightmap_size):
	material.set_shader_parameter("map_heightmap", height_texture)
	material.set_shader_parameter("map_normalmap", normal_map)
	material.set_shader_parameter("instance_spacing", spacing)
	material.set_shader_parameter("instance_rows", rows)
	material.set_shader_parameter("map_heightmap_size", heightmap_size)
	material.set_shader_parameter("__terrain_amplitude", height_multiplier)
	material.set_shader_parameter("size_difference_of_world", scale_multiplier)
	
func get_noise_y(x, z):
	var value = image.get_pixel(x, z).r
	return value

func modify_noise(noise):
	var new_image = noise.get_image()
	var black = Color.BLACK
	for x in range(world_size + 2):
		new_image.set_pixel(x, 0, black)
		new_image.set_pixel(x, 1, black)
		
		new_image.set_pixel(x, world_size + 0, black)
		new_image.set_pixel(x, world_size + 1, black)
		
	for y in range(2, world_size):
		new_image.set_pixel(0, y, black)
		new_image.set_pixel(1, y, black)
		
		new_image.set_pixel(world_size + 0, y, black)
		new_image.set_pixel(world_size + 1, y, black)
		
	
	return new_image
	
