extends CharacterBody3D

const SENSITIVITY = 0.004

const FALL_SPEED_MAX = 30
const JUMP_VELOCITY = 10.0

const TARGET_LERP = .7
var WALK_SPEED = 15.0
var acc_speed = 10.0

var gravity = 9.8 * 3

var is_grappling = false
var grapple_hook_position = Vector3.ZERO
const GRAPPLE_RAY_MAX = 100.0
const GRAPPLE_FORCE_MAX = 55.0
const GRAPPLE_MIN_DIST = 5.0

var input_dir = Vector2.ZERO
var direction = Vector3.ZERO

var current_max_speed : float = WALK_SPEED

@onready var head = $PlayerHead
@onready var camera = $PlayerHead/Camera3D
@onready var camera_cast = $PlayerHead/Camera3D/camera_cast
@onready var grapple_pivot = $PlayerGrapplePivot
@onready var grapple_point = $PlayerHead/Camera3D/camera_cast/point_of_grapple

@onready var debug0 = $PlayerHead/Camera3D/DebugLabel0
@onready var debug1 = $PlayerHead/Camera3D/DebugLabel1

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_cast.set_target_position(Vector3(0, 0, -1 * GRAPPLE_RAY_MAX))
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# grapple
	var grapple_raycast_hit = camera_cast.get_collider()
	if grapple_raycast_hit:
		grapple_point.global_position = camera_cast.get_collision_point()
	if Input.is_action_just_pressed("left_click"):
		if grapple_raycast_hit:
			grapple_hook_position = camera_cast.get_collision_point()
			is_grappling = true
		else:
			is_grappling = false
 
	if is_grappling && Input.is_action_pressed("left_click"):
		grapple_pivot.look_at(grapple_hook_position)
		var grapple_direction = (grapple_hook_position - position).normalized()
		
		if grapple_hook_position.distance_to(position) < GRAPPLE_MIN_DIST:
			var grapple_target_speed = grapple_direction * GRAPPLE_FORCE_MAX * grapple_hook_position.distance_to(position)/GRAPPLE_MIN_DIST
			velocity = grapple_target_speed
		else:
			var grapple_target_speed = grapple_direction * GRAPPLE_FORCE_MAX
			velocity = grapple_target_speed
	
	# movement
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = transform.basis * Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	var target_speed : Vector3 = direction * current_max_speed
	var jumped = false
	
	if Input.is_action_pressed("jump") and is_on_floor():
		jumped = true
		if input_dir:
			velocity *= 1.5
		else:
			velocity *= 0.9
		velocity.y = JUMP_VELOCITY
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
		
	if not input_dir and not jumped and is_on_floor():
		target_speed.x = 0.0
		target_speed.z = 0.0
		velocity.x *= 0.5
		velocity.z *= 0.5
	
	#calculate dif between max and current speed
	#ignore y axis
	var speed_difference : Vector3 = target_speed - velocity
	speed_difference.y = 0
 
	#final force that will be applied to character
	var movement = speed_difference * acc_speed
	
	if input_dir or (not jumped and is_on_floor()):
		velocity = velocity + (movement) * delta
	
		#elif not jumped and is_on_floor():
			#velocity.x = 0.0
			#velocity.z = 0.0
		#elif jumped and is_on_floor():
			#velocity.x *= 0.90
			#velocity.z *= 0.90
			
	move_and_slide()
	
	debug0.text = str(target_speed) + "\n " + str(velocity)
	
	
