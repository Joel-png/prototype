class_name TerrainGeneration
extends Node3D

var mesh: MeshInstance3D
var world_size: int = 100
var mesh_resolution: int = 1
var scale_multiplier: int = 8
var height_multiplier: int = 4 * scale_multiplier

var grass_scale: int = 7


@export var noise_texture: NoiseTexture2D
var image: Image
@export var mountain_noise_texture: NoiseTexture2D
var mountain_image: Image
@export var spike_noise_texture: NoiseTexture2D
var spike_image: Image
@export var spike_direction_noise_texture: NoiseTexture2D
var spike_direction_image: Image
@export var tree_noise_texture: NoiseTexture2D
var tree_image: Image
@export var flower_noise_texture: NoiseTexture2D
var flower_image: Image
@export var random_noise_texture: NoiseTexture2D
var random_image: Image

@export var mesh_instance: Mesh

@export var test_noise: NoiseTexture2D
@export var height_curve: Curve
@export var mountain_curve: Curve
@export var spike_scale_curve: Curve
@export var random_curve: Curve

var terrain_seed: int = 0

@onready var water = $Water
@onready var world = $".."
@onready var grass_clumps = $GrassClumpParticle
@onready var grass_spots = $GrassSpotParticle
@onready var rocks_small = $RockSmallParticle
@onready var shrubs = $ShrubParticle
@onready var spike_scene = preload("res://spike.tscn")
@onready var tree_scene = preload("res://tree.tscn")
@onready var flower_scene = preload("res://Assets/Terrain/Flower/flower.tscn")


func setup_noise(noise):
	noise.width = world_size + 2
	noise.height = world_size + 2
	noise.noise.seed = terrain_seed + 2

func noise_to_image(noise):
	setup_noise(noise)
	await noise.changed
	return noise

func setup() -> void:
	terrain_seed = world.terrain_seed
	
	print("Generating world with seed: " + str(terrain_seed))
	var grass_clumps_sm = grass_clumps.process_material
	var grass_spots_sm = grass_spots.process_material
	var rock_small_sm = rocks_small.process_material
	var shrubs_sm = shrubs.process_material
	
	image = modify_noise(await noise_to_image(noise_texture))
	
	mountain_image = modify_noise(await noise_to_image(mountain_noise_texture))
	
	spike_image = (await noise_to_image(spike_noise_texture)).get_image()
	
	spike_direction_image = (await noise_to_image(spike_direction_noise_texture)).get_image()
	
	tree_image = (await noise_to_image(tree_noise_texture)).get_image()
	
	flower_image = (await noise_to_image(flower_noise_texture)).get_image()
	
	random_image = (await noise_to_image(random_noise_texture)).get_image()
	
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
	var flower_count = 0
	
	var tree_positions = []
	
	for i in range(data.get_vertex_count()):
		var vertex = data.get_vertex(i)
		
		# get random offset
		var world_x = vertex.x + floor(world_size / 2.0) + 1
		var world_z = vertex.z + floor(world_size / 2.0) + 1
		
		var random_x = get_noise_y(random_image, world_x, world_z)
		var random_z = get_noise_z(random_image, world_x, world_z)
		
		var y = get_noise_y(image, world_x, world_z)
		var mountain_y = get_noise_y(mountain_image, world_x, world_z)
		var spikeness = get_noise_y(spike_image, world_x, world_z)
		var spike_directionness = get_noise_y(spike_direction_image, world_x, world_z)
		var treeness = get_noise_y(tree_image, world_x, world_z)
		var flowerness = get_noise_y(flower_image, world_x, world_z)
		
		var mountain_strength = 4.0
		
		var total_height = y * height_curve.sample(y)
		total_height += mountain_curve.sample(mountain_y) * mountain_strength
		
		vertex.y = total_height * height_multiplier
		vertex.x = vertex.x * scale_multiplier
		vertex.z = vertex.z * scale_multiplier
		
		var random_multiplier = 8.0
		var random_scale_multiplier = 3.0
		var random_vertex = Vector3.ZERO
		random_vertex.y = total_height * height_multiplier
		random_vertex.x = vertex.x + random_x * random_multiplier * scale_multiplier
		random_vertex.z = vertex.z + random_z * random_multiplier * scale_multiplier
		
		var spike_threshold = 0.5
		if spikeness > spike_threshold:
			
			spike_count += 1
			var new_scene = spike_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			add_child(new_scene)
			
			# updates the pixel looked at to get the adjusted height value, scale world coord to image coord
			var new_world_x = random_vertex.x / scale_multiplier + floor(world_size / 2.0) + 1
			var new_world_z = random_vertex.z / scale_multiplier + floor(world_size / 2.0) + 1
			var y_offset = get_noise_y(image, new_world_x, new_world_z)
			var mountain_y_offset = get_noise_y(mountain_image, new_world_x, new_world_z)
			var total_height_offset = y_offset * height_curve.sample(y_offset)
			total_height_offset += mountain_curve.sample(mountain_y_offset) * mountain_strength
			random_vertex.y = total_height_offset * height_multiplier
			new_scene.position.x = random_vertex.x
			new_scene.position.y = random_vertex.y
			new_scene.position.z = random_vertex.z
			var spike_scale = max(spikeness - spike_threshold + treeness, 0.1) * 10.0
			var vector_maker = spike_scale + spike_scale * random_x * random_scale_multiplier * (spike_scale_curve.sample(spikeness - spike_threshold))
			new_scene.scale = Vector3(vector_maker, vector_maker, vector_maker)
			new_scene.rotation.y = deg_to_rad(360.0 * spike_directionness)
			new_scene.rotation.z = deg_to_rad(45.0)
			
		
		if treeness > 0.5 and 0.7 > total_height and total_height > 0.3:
			var repeat: float = 10 #get_random_repeat(random_x, 10, 5) + 10
			
			# sets offset based on random noise and curve, adjust y value for new position
			for j in range(0, repeat):
				# change random amount from curve as iterating
				var offset_vertex = Vector3(random_vertex.x, random_vertex.y, random_vertex.z)
				var random_offset_x: float = random_curve.sample(random_x * j/repeat)
				var random_offset_z: float = random_curve.sample(random_z * j/repeat)
				offset_vertex.x += random_x * random_multiplier * scale_multiplier * random_offset_x
				offset_vertex.z += random_z * random_multiplier * scale_multiplier * random_offset_z
				
				var new_world_x = offset_vertex.x / scale_multiplier + floor(world_size / 2.0) + 1
				var new_world_z = offset_vertex.z / scale_multiplier + floor(world_size / 2.0) + 1
				var y_offset = get_noise_y(image, new_world_x, new_world_z)
				var mountain_y_offset = get_noise_y(mountain_image, new_world_x, new_world_z)
				var total_height_offset = y_offset * height_curve.sample(y_offset)
				total_height_offset += mountain_curve.sample(mountain_y_offset) * mountain_strength
				offset_vertex.y = total_height_offset * height_multiplier
				
				if 0.7 > total_height_offset and total_height_offset > 0.3:
					tree_count += 1
					tree_positions.append(offset_vertex)
			
		if flowerness > 0.5 and 0.35 > total_height and total_height > 0.3:
			flower_count += 1
			#var new_scene = flower_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
			#add_child(new_scene)
			#new_scene.position.x = vertex.x
			#new_scene.position.y = vertex.y
			#new_scene.position.z = vertex.z
			
		
		data.set_vertex(i, vertex)
	
	var mm_instance = MultiMeshInstance3D.new()
	var mm = MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh_instance
	
	mm.instance_count = tree_positions.size()
	print(mm.instance_count)
	print(mm.mesh)
	for i in range(tree_positions.size()):
		var vertex = tree_positions[i]
		var transform_tree = Transform3D(Basis(), vertex)
		mm.set_instance_transform(i, transform_tree)
	
	mm_instance.multimesh = mm
	add_child(mm_instance)
	
	print("Total Spikes: " + str(spike_count))
	print("Total Trees: " + str(tree_count))
	print("Total Flowers: " + str(flower_count))
	
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
	return get_pixel_bilinear(noise_image, x, z).r
	
func get_noise_z(noise_image, x, z):
	return get_pixel_bilinear(noise_image, x, z).b

# thank u chatgpt for this banger, the 5tons of water that went into creating this function will not be forgotten
func get_pixel_bilinear(img: Image, u: float, v: float) -> Color:
	var x = clamp(u, 0.0, img.get_width() - 1.0)
	var y = clamp(v, 0.0, img.get_height() - 1.0)
	
	var x0 = int(floor(x))
	var y0 = int(floor(y))
	var x1 = min(x0 + 1, img.get_width() - 1)
	var y1 = min(y0 + 1, img.get_height() - 1)
	
	var fx = x - x0
	var fy = y - y0
	
	var c00 = img.get_pixel(x0, y0)
	var c10 = img.get_pixel(x1, y0)
	var c01 = img.get_pixel(x0, y1)
	var c11 = img.get_pixel(x1, y1)
	
	var c0 = c00.lerp(c10, fx)
	var c1 = c01.lerp(c11, fx)
	return c0.lerp(c1, fy)

func get_random_repeat(value, multi, mod):
	value *= multi
	return ((int)(value) % mod)

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
