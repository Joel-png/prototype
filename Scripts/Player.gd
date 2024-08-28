extends CharacterBody3D

const SENSITIVITY = 0.004

const FALL_SPEED_MAX = 30
const JUMP_VELOCITY = 20.0

const TARGET_LERP = .7
var WALK_SPEED = 10.0
var acc_speed = 10.0
var too_fast_slow_down = 0.90

var gravity = 9.8 * 5

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

#inventory
@onready var inventory = $PlayerHead/Camera3D/Inventory

@onready var debug0 = $PlayerHead/Camera3D/DebugLabel0
@onready var debug1 = $PlayerHead/Camera3D/DebugLabel1

var holdable: Holdable = null
var grapple: Grapple = Grapple.new(self)
var shotgun: Shotgun = Shotgun.new(self)
var hotbar = [shotgun, grapple]
var hotbar_length = hotbar.size()
var hotbar_pressed = Array()
var hotbar_selected = 0



func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_cast.set_target_position(Vector3(0, 0, -1 * GRAPPLE_RAY_MAX))
	for object in hotbar:
		inventory.add_child(object.get_scene())
	
	select_holdable(hotbar[0])
	hotbar_pressed.resize(hotbar_length)
	hotbar_pressed.fill(false)
	
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	
	hotbar_logic()
	
	holdable.action()
	
	# movement
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
#	transform.basis * 
	var target_speed : Vector3 = direction * current_max_speed
	var jumped = false
	
	if Input.is_action_pressed("jump") and is_on_floor():
		jumped = true
		if input_dir:
			velocity *= too_fast_slow_down
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
	
	var local_velocity = transform.basis.inverse() * velocity
	
	#only if bhopping or midair
	if not (not jumped and is_on_floor()):
		#keep velocity if velocity is higher than movement could make
		if local_velocity.x < 0 and target_speed.x < 0 and local_velocity.x < -current_max_speed or local_velocity.x >= 0 and target_speed.x >= 0 and local_velocity.x > current_max_speed:
				target_speed.x = local_velocity.x
		if local_velocity.z < 0 and target_speed.z < 0 and local_velocity.z < -current_max_speed or local_velocity.z >= 0 and target_speed.z >= 0 and local_velocity.z > current_max_speed:
				target_speed.z = local_velocity.z
		
		#keep velocity when using a key that doesnt interupt velocity
		if input_dir.x == 0:
			target_speed.x = local_velocity.x
		if input_dir.y == 0:
			target_speed.z = local_velocity.z
	var speed_difference : Vector3 = target_speed - local_velocity
	speed_difference.y = 0
 
	#final force that will be applied to character
	var movement = speed_difference * acc_speed
	
	if input_dir or (not jumped and is_on_floor()):
		velocity = velocity + (transform.basis * movement) * delta
	move_and_slide()
	
	debug0.text = str(target_speed) + "\n " + str(velocity)
	#debug1.text = str(local_velocity) + "\n" + str(target_speed)
	
func hotbar_logic():
	var new_hotbar_selected = false
	for i in range(hotbar_pressed.size()):
		if Input.is_action_pressed(str(i+1)) and not hotbar_pressed[i]:
			hotbar_pressed[i] = true
			if hotbar_selected != i:
				hotbar_selected = i
				new_hotbar_selected = true
		elif not Input.is_action_pressed(str(i+1)) and hotbar_pressed[i]:
			hotbar_pressed[i] = false
			
	if new_hotbar_selected:
		select_holdable(hotbar[hotbar_selected])
		
	
func select_holdable(item_to_hold: Holdable):
	if holdable:
		holdable.deselect()
	holdable = item_to_hold
	holdable.select()
