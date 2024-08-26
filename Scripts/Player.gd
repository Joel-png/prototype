extends CharacterBody3D


const SPEED = 1.5
const MAX_MOVEMENT_SPEED = 50.0
const JUMP_VELOCITY = 5.5
const SENSITIVITY = 0.004

var gravity = 9.8
var movement := Vector3(0, 0, 0)

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		movement.y -= gravity * delta
	else:
		movement.y = 0.0

	var moving_x = false
	var moving_z = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var input := Vector3(input_dir.x, 0, input_dir.y)
	
	if input.x:
		moving_x = true
		movement.x += input.x * SPEED
		movement.x = clamp(movement.x, -MAX_MOVEMENT_SPEED, MAX_MOVEMENT_SPEED)
		
	if input.z:
		moving_z = true
		movement.z += input.z * SPEED
		movement.z = clamp(movement.z, -MAX_MOVEMENT_SPEED, MAX_MOVEMENT_SPEED)
		
	if input.x and not input.z:
		movement.z *= 0.80
		
	if input.z and not input.x:
		movement.x *= 0.80
	
	# Handle jump.
	var jumped = false
	if Input.is_action_pressed("jump") and is_on_floor():
		jumped = true
		movement *= 0.90
		movement.y = JUMP_VELOCITY
		
	movement = transform.basis.normalize() * movement
	var direction := movement
	
	if direction:
		if input:
			velocity.x = direction.x
			velocity.z = direction.z
		elif not jumped and is_on_floor():
			velocity.x = 0.0
			velocity.z = 0.0
		elif jumped and is_on_floor():
			velocity.x *= 0.90
			velocity.z *= 0.90
		
		
		#velocity.z = clamp(velocity.z, -MAX_SPEED, MAX_SPEED)
		
	
		
		
	
	if not jumped and is_on_floor() and not moving_x:
		movement.x *= 0.5
	if not jumped and is_on_floor() and not moving_z:
		movement.z *= 0.5

	velocity.y = movement.y
	move_and_slide()
	
	$Head/Camera3D/DebugLabel.text = "dvx:" + str(velocity.x) + "\ndvy:" + str(velocity.y) + "\ndvz:" + str(velocity.z) + "\ndx:" + str(movement.x) + "\ndy:" + str(movement.y) + "\ndz:" + str(movement.z)
	
