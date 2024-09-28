extends CharacterBody3D

const SENSITIVITY = 0.004

const FALL_SPEED_MAX = 30
const JUMP_VELOCITY = 15.0

const TARGET_LERP = .7
var WALK_SPEED = 10.0
var acc_speed = 10.0
var too_fast_slow_down = 0.90

var gravity = 9.8 * 4

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
@onready var crosshair = $PlayerHead/Camera3D/Crosshair
@onready var grapple_pivot = $PlayerGrapplePivot
@onready var animation_player = $AnimationPlayer
@onready var projectiles = $"../../Projectiles"
@onready var projectile_scene = preload("res://projectile.tscn")

#inventory
@onready var inventory = $PlayerHead/Camera3D/Inventory
@onready var holdable_spawner = $HoldableSpawner

@onready var debug0 = $PlayerHead/Camera3D/DebugLabel0
@onready var debug1 = $PlayerHead/Camera3D/DebugLabel1

var holdable: Holdable = null
var grapple: Grapple
var shotgun: Shotgun
var hotbar = []
var hotbar_length = hotbar.size()
var hotbar_selected = 0
var hotbar_to_select = 0
var is_player
var is_focus = true


func _ready():
	holdable_spawner.spawn_function = spawn_holdable
	grapple = Grapple.new(self)
	shotgun = Shotgun.new(self)
	hotbar = [shotgun.get_self(), grapple.get_self()]
	is_player = is_multiplayer_authority()
	camera.current = is_player
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_cast.set_target_position(Vector3(0, 0, -1 * GRAPPLE_RAY_MAX))
	#for object in hotbar:
		#inventory.add_child(object)
	
	select_holdable(0)
	
	if !is_player:
		debug0.hide()
		debug1.hide()
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 144
	
	
func _unhandled_input(event):
	if is_focus:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta):
	is_player = is_multiplayer_authority()
	
	if is_player:
		hotbar_logic()
		if Input.is_action_just_pressed("Escape"):
			if is_focus:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				is_focus = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				is_focus = true
			
		holdable.action(delta)
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
		debug1.text = str(Engine.get_frames_per_second()) + " " + str(1.0/(get_process_delta_time()))
	holdable.end_action()
	
func hotbar_logic():
	if is_player:
		for i in range(hotbar.size()):
			if Input.is_action_pressed(str(i+1)):
				if hotbar_to_select != i:
					hotbar_to_select = i
			
	if hotbar_to_select != hotbar_selected:
		select_holdable.rpc(hotbar_to_select)
		hotbar_selected = hotbar_to_select
		

@rpc("any_peer", "call_local")
func select_holdable(item_to_hold):
	if holdable:
		holdable.deselect()
	holdable = hotbar[item_to_hold]
	holdable.select()
	
func spawn_holdable(data):
	var h = (load(data) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	print(data)
	return h
	
@rpc("any_peer", "call_local")
func spawn_projectile(pos, rot):
	var p = projectile_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	p._setup(pos, rot)
	projectiles.add_child(p)
	return p

@rpc("any_peer", "call_local")
func shoot_animation():
	animation_player.stop()
	animation_player.play("shoot")
	
func shoot(pos, rot, config):
	#[speed, firerate, bullet_spread_hor, bullet_spread_ver, bloom_hor, bloom_ver]
	var base_rot = rot
	var bullet_spread_hor = config[2]
	var bullet_spread_ver = config[3]
	var bloom_hor = config[4]
	var bloom_ver = config[5]
	for _x in range(-bloom_hor, bloom_hor + 1, max(1, bloom_hor * 2) / bullet_spread_hor):
		for _y in range(-bloom_ver, bloom_ver + 1, max(1, bloom_ver * 2) / bullet_spread_ver):
			var rot_with_bloom = base_rot
			rot_with_bloom.y += deg_to_rad(_x)
			rot_with_bloom.x += deg_to_rad(_y)
			print(rot_with_bloom)
			spawn_projectile.rpc(pos, rot_with_bloom)
	shoot_animation.rpc()
