extends Holdable
class_name Grapple

var is_grappling = false
var grapple_hook_position = Vector3.ZERO
const GRAPPLE_RAY_MAX = 100.0
const GRAPPLE_FORCE_MAX = 55.0
const GRAPPLE_MIN_DIST = 2.0

func _init(new_overseer):
	super._init(new_overseer)
	
	scene = load("res://grapple.tscn").instantiate()
	scene.visible = false

func action():
	var grapple_raycast_hit = overseer.camera_cast.get_collider()
	if Input.is_action_just_pressed("left_click"):
		if grapple_raycast_hit:
			grapple_hook_position = overseer.camera_cast.get_collision_point()
			is_grappling = true
		else:
			is_grappling = false
 
	if is_grappling && Input.is_action_pressed("left_click"):
		overseer.grapple_pivot.look_at(grapple_hook_position)
		var grapple_direction = (grapple_hook_position - overseer.position).normalized()
		overseer.debug1.text = str(grapple_hook_position.distance_to(overseer.position))
		
		if grapple_hook_position.distance_to(overseer.position) < GRAPPLE_MIN_DIST:
			var grapple_target_speed = grapple_direction * GRAPPLE_FORCE_MAX * grapple_hook_position.distance_to(overseer.position)/GRAPPLE_MIN_DIST
			overseer.velocity = grapple_target_speed
		else:
			var grapple_target_speed = grapple_direction * GRAPPLE_FORCE_MAX
			overseer.velocity = grapple_target_speed
