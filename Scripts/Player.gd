extends CharacterBody3D

const SENSITIVITY = 0.004

const FALL_SPEED_MAX = 30
const JUMP_VELOCITY = 4.5

const TARGET_LERP = .9
var WALK_SPEED = 15.0
var acc_speed = 20.0

var gravity = 9.8

var is_grappling = false

var input_dir = Vector2.ZERO
var direction = Vector3.ZERO

var current_max_speed : float = WALK_SPEED

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var camera_cast = $Head/Camera3D/camera_cast

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
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
	
	$Head/Camera3D/DebugLabel.text = str(target_speed) + "\n " + str(velocity)
	
