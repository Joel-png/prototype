extends Holdable
class_name Grapple

const GRAPPLE_RAY_MAX: float = 500.0
const GRAPPLE_FORCE_MAX: float = 150.0
const GRAPPLE_MIN_DIST: float = 2.0

var vertex_array: PackedVector3Array = []
var index_array: PackedInt32Array = []
var normal_array: PackedVector3Array = []
 
var tangent_array: PackedVector3Array = []
var uv_array: PackedVector2Array = []
var rope_width: float = 0.04
var resolution: int = 4

@onready var grapple_point = $GrapplePoint
@onready var grapple_mesh = $GrapplePoint/mesh

var mesh = ImmediateMesh.new()

func _ready() -> void:
	overseer = get_parent().player

func action(_delta: float) -> void:
	var grapple_raycast_hit = overseer.camera_cast.get_collider()
	crosshair_info(grapple_raycast_hit)
	
	if Input.is_action_just_pressed("left_click"):
		if grapple_raycast_hit:
			overseer.grapple_hook_position = overseer.camera_cast.get_collision_point()
			overseer.is_grappling = true
		else:
			overseer.is_grappling = false
 
	if overseer.is_grappling and Input.is_action_pressed("left_click"):
		overseer.grapple_pivot.look_at(overseer.grapple_hook_position)
		var grapple_direction: Vector3 = (overseer.grapple_hook_position - overseer.position).normalized()
		
		if overseer.grapple_hook_position.distance_to(overseer.position) < GRAPPLE_MIN_DIST:
			var grapple_target_speed: Vector3 = grapple_direction * GRAPPLE_FORCE_MAX * max(0, overseer.grapple_hook_position.distance_to(overseer.position) - GRAPPLE_MIN_DIST * 0.2)/GRAPPLE_MIN_DIST
			overseer.velocity = grapple_target_speed
		else:
			var grapple_target_speed: Vector3 = grapple_direction * GRAPPLE_FORCE_MAX
			overseer.velocity = grapple_target_speed
			
	if overseer.is_grappling and not Input.is_action_pressed("left_click"):
		overseer.is_grappling = false

func end_action() -> void:
	if overseer.is_grappling:
		show_mesh.rpc()
	else:
		if grapple_mesh.visible:
			hide_mesh.rpc()
	
@rpc("any_peer", "call_local")
func show_mesh() -> void:
	create_rope_mesh()
	grapple_mesh.visible = true

@rpc("any_peer", "call_local")
func hide_mesh() -> void:
	grapple_mesh.visible = false

func crosshair_info(ray_hit) -> void:
	var string_for_crosshair: String = ""
	if ray_hit:
		var meters_to_grapple: float = overseer.camera_cast.get_collision_point().distance_to(overseer.camera_cast.global_position)
		if int(meters_to_grapple * 10) % 10 == 0:
			string_for_crosshair = str(floor(meters_to_grapple* 10)/10.0) + ".0m"
		else:
			string_for_crosshair = str(floor(meters_to_grapple * 10)/10.0) + "m"
	else:
		string_for_crosshair = "|-----|"
	overseer.crosshair.display_crosshair_text(string_for_crosshair)

func create_rope_mesh() -> void:
	var points : PackedVector3Array = []
	points.append(grapple_point.global_position - grapple_point.position)
	points.append(overseer.grapple_hook_position - grapple_point.position)
	
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
	grapple_mesh.mesh = mesh

func calculate_rope_normal() -> void:
	var points : PackedVector3Array = []
	points.append(grapple_point.global_position - grapple_point.position)
	points.append(overseer.grapple_hook_position - grapple_point.position)
	
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
