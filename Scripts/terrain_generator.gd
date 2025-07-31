class_name TerrainGeneration
extends Node3D

var mesh: MeshInstance3D
var world_size: int = 400
var mesh_resolution: int = 1
var scale_multiplier: int = 8
var height_multiplier: int = 4 * scale_multiplier

var grass_scale: int = 7


@export var noise_texture: NoiseTexture2D
@export var mountain_noise_texture: NoiseTexture2D
@export var spike_noise_texture: NoiseTexture2D
@export var spike_direction_noise_texture: NoiseTexture2D
@export var tree_noise_texture: NoiseTexture2D

@export var test_noise: NoiseTexture2D
@export var height_curve: Curve
@export var mountain_curve: Curve

var terrain_seed: int = 0
var image: Image
var mountain_image: Image
var spike_image: Image
var spike_direction_image: Image
var tree_image: Image

@onready var water = $Water
@onready var world = $".."
@onready var grass_clumps = $GrassClumpParticle
@onready var grass_spots = $GrassSpotParticle
@onready var rocks_small = $RockSmallParticle
@onready var shrubs = $ShrubParticle
@onready var spike_scene = preload("res://spike.tscn")
@onready var tree_scene = preload("res://tree.tscn")

func setup_noise(noise):
	noise.width = world_size + 2
	noise.height = world_size + 2
	noise.noise.seed = terrain_seed + 2

func setup() -> void:
	terrain_seed = world.terrain_seed
	
	print("Generating world with seed: " + str(terrain_seed))
	var grass_clumps_sm = grass_clumps.process_material
	var grass_spots_sm = grass_spots.process_material
	var rock_small_sm = rocks_small.process_material
	var shrubs_sm = shrubs.process_material
	
	setup_noise(noise_texture)
	await noise_texture.changed
	image = modify_noise(noise_texture)
	
	setup_noise(mountain_noise_texture)
	await mountain_noise_texture.changed
	mountain_image = modify_noise(mountain_noise_texture)
	
	setup_noise(spike_noise_texture)
	await spike_noise_texture.changed
	spike_image = spike_noise_texture.get_image()
	
	
	setup_noise(spike_direction_noise_texture)
	await spike_direction_noise_texture.changed
	spike_direction_image = spike_direction_noise_texture.get_image()
	
	setup_noise(tree_noise_texture)
	await tree_noise_texture.changed
	tree_image = tree_noise_texture.get_image()
	
	var height_texture = ImageTexture.new()
	height_texture.set_image(image)
	
	var normal_map = ImageTexture.new()
	var normal_image = Image.new()
	normal_image.copy_from(image)
	normal_image.bump_map_to_normal_map(height_multiplier)
	#normal_image.save_png("res://Assets/normalmap.png")
	
	normal_map.set_image(normal_image)
	
	var heightmap_scale: int = world_size + 2
	var heightmap_size: Vector2 = Vector2(heightmap_scale, heightmap_scale)
	var rows: int = 100 * grass_scale
	var base_spacing: float = 0.25 # spacing at which is considered the default render distance for other spacings
	var grass_clumps_spacing: float = 0.25
	var grass_spots_spacing: float = 1.0
	var rocks_small_spacing: float = 4.0
	var shrubs_spacing: float = 10.0
	var clumps_rows: int = floor(rows * (base_spacing / grass_clumps_spacing))
	var spots_rows: int = floor(rows * (base_spacing / grass_spots_spacing))
	var rocks_small_rows: int = floor(rows * (base_spacing / rocks_small_spacing))
	var shrubs_rows: int = floor(rows * (base_spacing / shrubs_spacing))
	grass_clumps.amount = clumps_rows*clumps_rows
	grass_spots.amount = spots_rows*spots_rows
	rocks_small.amount = rocks_small_rows*rocks_small_rows
	shrubs.amount = shrubs_rows*shrubs_rows
	var water_height: float = height_multiplier * 0.3
	var coverage_range: float = height_multiplier
	var coverage_alt: float = water_height + height_multiplier
	setup_shader(grass_clumps_sm, height_texture, normal_map, grass_clumps_spacing, clumps_rows, heightmap_size, coverage_range, coverage_alt)
	setup_shader(grass_spots_sm, height_texture, normal_map, grass_spots_spacing, spots_rows, heightmap_size, coverage_range, coverage_alt)
	setup_shader(rock_small_sm, height_texture, normal_map, rocks_small_spacing, rocks_small_rows, heightmap_size, coverage_range, coverage_alt)
	setup_shader(shrubs_sm, height_texture, normal_map, shrubs_spacing, shrubs_rows, heightmap_size, coverage_range, coverage_alt)
	
	water_setup(water_height)
	
	generate()

func generate():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(world_size + 1, world_size + 1)
	plane_mesh.subdivide_depth = world_size * mesh_resolution
	plane_mesh.subdivide_width = world_size * mesh_resolution
	#var material = preload("res://Materials/ground_material.tres")
	var material = preload("res://Materials/sand_material.tres")
	material.set_shader_parameter("uv_scale", world_size * scale_multiplier / 5.0)
	plane_mesh.material = material
	
	var surface = SurfaceTool.new()
	var data = MeshDataTool.new()
	surface.create_from(plane_mesh, 0)
	
	var array_plane = surface.commit()
	data.create_from_surface(array_plane, 0)
	
	var spike_count = 0
	var tree_count = 0
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		var y = get_noise_y(image, vertex.x + floor(world_size / 2.0) + 1, vertex.z + floor(world_size / 2.0) + 1)
		var mountain_y = get_noise_y(mountain_image, vertex.x + floor(world_size / 2.0) + 1, vertex.z + floor(world_size / 2.0) + 1)
		var spikeness = get_noise_y(spike_image, vertex.x + floor(world_size / 2.0) + 1, vertex.z + floor(world_size / 2.0) + 1)
		var spike_directionness = get_noise_y(spike_direction_image, vertex.x + floor(world_size / 2.0) + 1, vertex.z + floor(world_size / 2.0) + 1)
		var treeness = get_noise_y(tree_image, vertex.x + floor(world_size / 2.0) + 1, vertex.z + floor(world_size / 2.0) + 1)
		
		vertex.y = y * height_multiplier * height_curve.sample(y)
		vertex.y += height_multiplier * mountain_curve.sample(mountain_y) * 4.0
		vertex.x = vertex.x * scale_multiplier
		vertex.z = vertex.z * scale_multiplier
		
		if spikeness > 0.5:
			spike_count += 1
			var new_scene = spike_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			add_child(new_scene)
			new_scene.position.x = vertex.x
			new_scene.position.y = vertex.y
			new_scene.position.z = vertex.z
			var spike_scale = max(treeness, 0.1) * 10.0
			new_scene.scale = Vector3(spike_scale, spike_scale, spike_scale)
			new_scene.rotation.y = deg_to_rad(360.0 * spike_directionness)
			new_scene.rotation.z = deg_to_rad(45.0)
			
		
		if treeness > 0.5:
			tree_count += 1
			var new_scene = tree_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			add_child(new_scene)
			new_scene.position.x = vertex.x
			new_scene.position.y = vertex.y
			new_scene.position.z = vertex.z
			
		
		data.set_vertex(i, vertex)
	
	print("Total Spikes: " + str(spike_count))
	print("Total Trees: " + str(tree_count))
	
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
	

func setup_shader(material, height_texture, normal_map, spacing, rows, heightmap_size, coverage_range, coverage_alt):
	material.set_shader_parameter("map_heightmap", height_texture)
	material.set_shader_parameter("map_normalmap", normal_map)
	material.set_shader_parameter("instance_spacing", spacing)
	material.set_shader_parameter("instance_rows", rows)
	material.set_shader_parameter("map_heightmap_size", heightmap_size)
	material.set_shader_parameter("__terrain_amplitude", height_multiplier)
	material.set_shader_parameter("size_difference_of_world", scale_multiplier)
	material.set_shader_parameter("_coverage_range", coverage_range)
	material.set_shader_parameter("_coverage_altitude", coverage_alt)

func get_noise_y(noise_image, x, z):
	var value = noise_image.get_pixel(x, z).r
	return value

func modify_noise(noise):
	var edge_damp = floor(world_size / 5.0)
	var new_image = noise.get_image()
	var colour
	for i in range(edge_damp):
		var colour_mul = i/edge_damp
		for x in range(world_size + 2):
			colour = mul_colour(new_image.get_pixel(x, i), colour_mul)
			new_image.set_pixel(x, i, colour)
			
			colour = mul_colour(new_image.get_pixel(x, world_size + 1 - i), colour_mul)
			new_image.set_pixel(x, world_size + 1 - i, colour)
			
		for y in range(1, world_size + 1):
			colour = mul_colour(new_image.get_pixel(i, y), colour_mul)
			new_image.set_pixel(i, y, colour)
			
			colour = mul_colour(new_image.get_pixel(world_size + 1 - i, y), colour_mul)
			new_image.set_pixel(world_size + 1 - i, y, colour)
			
	return new_image
	

func mul_colour(colour: Color, val: float):
	colour.r *= val
	colour.g *= val
	colour.b *= val
	return colour
	
func water_setup(water_height: float):
	water.position.y = water_height
	var water_mesh = water.mesh
	var mesh_scale = world_size * scale_multiplier * 4
	water_mesh.size = Vector2(mesh_scale, mesh_scale)
	var material = water.mesh.material
	material.set_shader_parameter("uv_scale", world_size * scale_multiplier / 2.0)
