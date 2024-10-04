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
var rng = RandomNumberGenerator.new()



@onready var head = $PlayerHead
@onready var camera = $PlayerHead/Camera3D
@onready var camera_cast = $PlayerHead/Camera3D/camera_cast
@onready var crosshair = $PlayerHead/Camera3D/Crosshair
@onready var grapple_pivot = $PlayerGrapplePivot
@onready var animation_player = $AnimationPlayer
@onready var projectiles = $"../../Projectiles"
@onready var projectile_scene = preload("res://projectile.tscn")
@onready var grapple_scene = preload("res://grapple.tscn")
@onready var shotgun_scene = preload("res://shotgun.tscn")
@onready var gun_scene = preload("res://gun.tscn")

#inventory
@onready var inventory = $PlayerHead/Camera3D/Inventory

@onready var debug0 = $PlayerHead/Camera3D/DebugLabel0
@onready var debug1 = $PlayerHead/Camera3D/DebugLabel1

var holdable: Holdable = null
var grapple: Grapple
var gun: Gun
var shotgun: Shotgun
var hotbar = []
var hotbar_length = hotbar.size()
var hotbar_selected = 0
var hotbar_to_select = 0
var is_player
var is_focus = false
var test_degree = [90, 90]


func _ready():
	grapple = grapple_scene.instantiate()
	grapple.init(self)
	shotgun = shotgun_scene.instantiate()
	shotgun.init(self)
	gun = gun_scene.instantiate()
	gun.init(self)
	hotbar = [gun, shotgun, grapple]
	is_player = is_multiplayer_authority()
	camera.current = is_player
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_cast.set_target_position(Vector3(0, 0, -1 * GRAPPLE_RAY_MAX))
	#for object in hotbar:
		#inventory.add_child(object)
	
	select_holdable(0)
	
	if !is_player:
		debug0.hide()
		debug1.hide()
	else:
		#DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 144
	
	
func _unhandled_input(event):
	if is_focus:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta):
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
			
		#holdable.action(delta)
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
		holdable.action(delta)
		debug0.text = str(rad_to_deg(camera.rotation.x)) + "\n " + str(velocity) + "\n " + str(global_position)
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
	

@rpc("any_peer", "call_local")
func spawn_projectile(pos, rot, config):
	var p = projectile_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	projectiles.add_child(p)
	p._setup(pos, rot, config, camera.global_rotation)
	return p

@rpc("any_peer", "call_local")
func shoot_animation():
	holdable.muzzle.flash()
	animation_player.stop()
	animation_player.play("shoot")
	
func shoot(pos, _rot, config):
	#[speed, firerate, bullet_spread_hor, bullet_spread_ver, bloom_hor, bloom_ver]
	var bullet_spread_hor = config[2]
	var bullet_spread_ver = config[3]
	var bloom_hor = config[4]
	var bloom_ver = config[5]
	for _x in range(bullet_spread_hor):
		for _y in range(bullet_spread_ver):
			var bloom_y = deg_to_rad(calc_bloom(bloom_hor, bullet_spread_hor, _x))
			var bloom_x = deg_to_rad(calc_bloom(bloom_ver, bullet_spread_ver, _y))
			spawn_projectile.rpc(pos, get_what_look_at(), [config[0], bloom_x, bloom_y])
	shoot_animation.rpc()

func calc_bloom(bloom, proj_amount, i):
	var bloom_inc = float(bloom * 2) / proj_amount
	var lower_bloom = (-bloom) + bloom_inc * i
	var upper_bloom = (-bloom) + bloom_inc * (i + 1)
	#return rng.randf_range(lower_bloom, upper_bloom)
	return (lower_bloom + upper_bloom) / 2
	
func get_what_look_at():
	# if point to shoot at is too close bullets will go to the side | if point isn't in raycast
	if camera_cast.get_collider():
		if position.distance_to(camera_cast.get_collision_point()) > 2:
			return camera_cast.get_collision_point()
	var forward_direction = -camera_cast.global_transform.basis.z.normalized()
	return camera_cast.global_transform.origin + forward_direction * 100
