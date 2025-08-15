extends Holdable
class_name Rod

var random_scaler = 0.5

var casting: bool = false
var fishing: bool = false

var fish_time: float = 1.0
var fish_counter: float = 0.0

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
@export var resolution: int = 4
@export var subdivide: int = 2
@export var sag_amount: float = 1.0

@export var catching_curve: Curve
@export var catch_tight_time: float = 0.5

var mesh = ImmediateMesh.new()

func _ready() -> void:
	overseer = get_parent().player
	

func action(_delta: float) -> void:
	if is_focus():
		if not fishing:
			if Input.is_action_just_pressed("left_click"):
				if not casting:
					cast()
				elif casting and not fishing:
					finish_cast.rpc()
	if not fishing:
		if casting and hook.hit_water:
			print("hit water")
			fishing = true
			fish_counter = fish_time
	else:
		fish_counter -= _delta
		if fish_counter <= 0.0:
			print("fished")
			fishing = false
			fish()
			finish_cast.rpc()

func cast():
	cast_hook.rpc(global_position, Vector3(0.0, global_rotation.y, 0.0), overseer.get_what_look_at())

@rpc("any_peer", "call_local")
func cast_hook(pos, rot, look_at_pos):
	hook.cast(pos, rot, look_at_pos)
	casting = true
	hook.show()
	print(casting)

@rpc("any_peer", "call_local")
func finish_cast():
	casting = false
	hook.hide()

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

func _process(_delta):
	if selected:
		if casting:
			hook._process_hook(_delta)
			create_rope_mesh()

func create_rope_mesh() -> void:
	var points : PackedVector3Array = []
	var start_point = line_start.global_position
	var end_point = hook.global_position
	for i in range(subdivide + 1): # +1 so we include the last point
		var t = float(i) / subdivide
		var pos = start_point.lerp(end_point, t)
		var sag = sag_amount * (1.0 - (2.0 * t - 1.0) * (2.0 * t - 1.0))
		pos.y -= sag
		points.append(pos)
	
	vertex_array.clear()
	
	calculate_rope_normal(points)
	
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

func calculate_rope_normal(_points) -> void:
	normal_array.clear()
	tangent_array.clear()
	
	for i in range(_points.size()):
		var tangent := Vector3(0,0,0)
		var normal := Vector3(0,0,0)
		var temp_helper_vector := Vector3(0,0,0)
		
		if i + 1 < _points.size():
			tangent = (_points[i + 1] - _points[i]).normalized()
		else:
			tangent = (_points[i] - _points[i - 1]).normalized()
		
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
