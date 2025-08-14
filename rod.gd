extends Holdable
class_name Rod

var base_action_cooldown: float = 1
var action_cooldown: float = 1
var cast_speed: float = 2.0
var random_scaler = 0.5

@onready var fish_manager = get_tree().get_nodes_in_group("FishManager")[0]
@onready var hook = $Hook
@onready var line_start = $Pivot/LineStart
@onready var line_mesh = $Line

var vertex_array: PackedVector3Array = []
var index_array: PackedInt32Array = []
var normal_array: PackedVector3Array = []
 
var tangent_array: PackedVector3Array = []
var uv_array: PackedVector2Array = []
var rope_width: float = 0.15
var resolution: int = 4

var mesh = ImmediateMesh.new()

func _ready() -> void:
	overseer = get_parent().player
	

func action(_delta: float) -> void:
	if is_focus():
		if Input.is_action_just_pressed("left_click"):
			hook.cast(global_position, Vector3(0.0, global_rotation.y, 0.0), overseer.get_what_look_at())
			fish()

func fish():
	var random_droprate = fish_manager.get_random_droprate()
	print(random_droprate)
	var new_fish = fish_manager.get_fish_from_droprate(random_droprate)
	new_fish.rarity = set_rarity()
	new_fish.apply_rarity_to_variables()
	overseer.inventory.add_item(new_fish)

func set_rarity():
	var rarity = (1.0 - 1.0 * random_scaler) + (int)(randi_range(1, 100) * random_scaler) / 100.0
	rarity = min(1.0, rarity)
	return rarity

func end_action(_delta):
	hook._process_hook(_delta)
	create_rope_mesh()
	
func create_rope_mesh() -> void:
	var points : PackedVector3Array = []
	points.append(line_start.global_position)
	points.append(hook.global_position)
	
	vertex_array.clear()
	
	calculate_rope_normal()
	
	index_array.clear()
	
	for p in range(points.size()):
		var norm = normal_array[p]
		var forward = tangent_array[p]
		var bitangent = norm.cross(forward).normalized()
		
		for c in range(resolution):
			var angle = (float(c) / resolution) * 2.0 * PI
			
			var xVal = sin(angle) * rope_width
			var yVal = cos(angle) * rope_width
			var point = (norm * xVal) + (bitangent * yVal) + points[p]
			
			vertex_array.append(point)
			
			if p < points.size() - 1:
				var start_index = resolution * p
				#INT values
				index_array.append(start_index + c);
				index_array.append(start_index + c + resolution);
				index_array.append(start_index + (c + 1) % resolution);
				
				index_array.append(start_index + (c + 1) % resolution);
				index_array.append(start_index + c + resolution);
				index_array.append(start_index + (c + 1) % resolution + resolution);
	
	mesh.clear_surfaces()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for i in range(floor(index_array.size() / 3.0)):
		var p1 = vertex_array[index_array[3*i]]
		var p2 = vertex_array[index_array[3*i+1]]
		var p3 = vertex_array[index_array[3*i+2]]
		
		var tangent = Plane(p1, p2, p3)
		var normal = tangent.normal
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p1)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p2)
		
		mesh.surface_set_tangent(tangent)
		mesh.surface_set_normal(normal)
		mesh.surface_add_vertex(p3)
	
	# End drawing.
	mesh.surface_end()
	line_mesh.mesh = mesh

func calculate_rope_normal() -> void:
	var points : PackedVector3Array = []
	points.append(line_start.global_position)
	points.append(hook.global_position)
	
	normal_array.clear()
	tangent_array.clear()
	
	for i in range(points.size()):
		var tangent := Vector3(0,0,0)
		var normal := Vector3(0,0,0)
		var temp_helper_vector := Vector3(0,0,0)
		
		tangent = (points[1] - points[0]).normalized()
		
		if i == 0:
			temp_helper_vector = -Vector3.FORWARD if (tangent.dot(Vector3.UP) > 0.5) else Vector3.UP
			normal = temp_helper_vector.cross(tangent).normalized()
		else:
			var tangent_prev = tangent_array[i-1]
			var normal_prev = normal_array[i-1]
			var bitangent = tangent_prev.cross(tangent)
			
			if bitangent.length() == 0:
				normal = normal_prev
			else:
				var bitangent_dir = bitangent.normalized()
				var theta = acos(tangent_prev.dot(tangent))
				
				var rotate_matrix = Basis(bitangent_dir, theta)
				normal = rotate_matrix * normal_prev
		
		tangent_array.append(tangent)
		normal_array.append(normal)
