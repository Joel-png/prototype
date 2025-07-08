extends CharacterBody3D

const SENSITIVITY: float = 0.004

const FALL_SPEED_MAX: float = 30.0
const JUMP_VELOCITY: float = 15.0

const TARGET_LERP: float = 0.7
var WALK_SPEED: float = 10.0
var acc_speed: float = 10.0
var too_fast_slow_down: float = 0.90

var gravity: float = 9.8 * 4

var is_grappling: bool = false
var grapple_hook_position: Vector3 = Vector3.ZERO
const GRAPPLE_RAY_MAX: float = 500.0
const GRAPPLE_FORCE_MAX: float = 55.0
const GRAPPLE_MIN_DIST: float = 5.0

var input_dir: Vector2 = Vector2.ZERO
var direction: Vector3 = Vector3.ZERO

var current_max_speed: float = WALK_SPEED
var rng = RandomNumberGenerator.new()

var noise_level = 0.0
var noise_decrease = 1.0
var noise_increase = 2.0


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
@onready var rod_scene = preload("res://rod.tscn")
@onready var instrument_scene = preload("res://instrument.tscn")

@onready var marker = $Marker
@onready var player_manager = $".."

#inventory
@onready var grapple_spawner = $MSGrapple
@onready var instrument_spawner = $MSInstrument
@onready var grimoire_spawner = $MSGrimoire
@onready var inventory = $PlayerHead/Camera3D/Inventory

@onready var debug0 = $PlayerHead/Camera3D/DebugLabel0
@onready var debug1 = $PlayerHead/Camera3D/DebugLabel1

var holdable: Holdable = null
var grapple: Grapple
var gun: Gun
var shotgun: Shotgun
var rod: Rod
var instrument: Instrument
var hotbar = []
var hotbar_length: int = hotbar.size()
var hotbar_selected: int = 0
var hotbar_to_select: int = 0
var is_player: bool
var is_focus: bool = false

func _ready() -> void:
	hotbar = []
	is_player = is_multiplayer_authority()
	camera.current = is_player
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera_cast.set_target_position(Vector3(0, 0, -1 * GRAPPLE_RAY_MAX))
	
	if !is_player:
		debug0.hide()
		debug1.hide()
	else:
		var auth = get_multiplayer_authority()
		spawn_item(instrument_spawner.spawn(auth))
		spawn_item(grapple_spawner.spawn(auth))
		spawn_item(grimoire_spawner.spawn(auth))
		marker.hide()
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		Engine.max_fps = 1000
		select_holdable(0)

func spawn_item(item) -> void:
	hotbar.append(item)
	item.deselect.rpc()
	
func calc_noise(delta):
	if noise_level > 0.0:
		noise_level -= noise_decrease * delta + noise_level * 0.5 * delta
		noise_level = max(0, noise_level)

func _unhandled_input(event) -> void:
	if is_focus:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _process(delta: float) -> void:
	is_player = is_multiplayer_authority()
	
	if is_player:
		calc_noise(delta)
		hotbar_logic()
		if Input.is_action_just_pressed("Escape"):
			if is_focus:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				$PlayerHead/Camera3D/Inventory/Inventory.show()
				is_focus = false
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				$PlayerHead/Camera3D/Inventory/Inventory.hide()
				is_focus = true
			
		if holdable:
			holdable.action(delta)
		# movement
		input_dir = Input.get_vector("left", "right", "up", "down")
		direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
		
	#	transform.basis * 
		var target_speed: Vector3 = direction * current_max_speed
		var jumped: bool = false
		
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
		
		var local_velocity: Vector3 = transform.basis.inverse() * velocity
		
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
		var speed_difference: Vector3 = target_speed - local_velocity
		speed_difference.y = 0
	 
		#final force that will be applied to character
		var movement: Vector3 = speed_difference * acc_speed
		
		if input_dir or (not jumped and is_on_floor()):
			velocity = velocity + (transform.basis * movement) * delta
		
		var moving_amount = Vector3(0, 0, 0).distance_to(velocity)
		if moving_amount > 0.01:
			var delta_calc = moving_amount * delta
			noise_level += noise_increase * delta_calc
		move_and_slide()
		#holdable.action(delta)
		debug0.text = str(moving_amount) + "\n " + str(velocity) + "\n " + str(noise_level)
		debug1.text = str(Engine.get_frames_per_second()) + " " + str(1.0/(get_process_delta_time()))
		
		get_parent_node_3d().update_grass(position)
		
		player_manager.main_player_position = position
	else:
		scale_marker(position.distance_to(player_manager.main_player_position))
	if holdable:
		holdable.end_action()
	
func hotbar_logic() -> void:
	if is_player:
		for i in range(hotbar.size()):
			if Input.is_action_pressed(str(i+1)):
				if hotbar_to_select != i:
					hotbar_to_select = i
			
	if hotbar_to_select != hotbar_selected:
		select_holdable(hotbar_to_select)
		hotbar_selected = hotbar_to_select
		

#@rpc("any_peer", "call_local")
func select_holdable(item_to_hold: int) -> void:
	if holdable:
		holdable.deselect.rpc()
	holdable = hotbar[item_to_hold]
	holdable.select.rpc()
	


func cast_spell(pos, rot, spell_type, damage, projectile_count, cast_cost):
	print("spawn proj" + spell_type + " " + str(damage) + " " + str(projectile_count) + " " + str(cast_cost))
	cast_projectile.rpc(pos, rot, spell_type, damage, projectile_count, cast_cost)

@rpc("any_peer", "call_local")
func cast_projectile(pos, rot, spell_type, damage, projectile_count, cast_cost):
	pass

@rpc("any_peer", "call_local")
func spawn_projectile(pos: Vector3, rot: Vector3, config):
	var p = projectile_scene.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
	projectiles.add_child(p)
	p._setup(pos, rot, config, camera.global_rotation)
	return p

@rpc("any_peer", "call_local")
func shoot_animation() -> void:
	holdable.muzzle.flash()
	animation_player.stop()
	animation_player.play("shoot")
	
func shoot(pos: Vector3, _rot: Vector3, config) -> void:
	#[speed, firerate, bullet_spread_hor, bullet_spread_ver, bloom_hor, bloom_ver]
	var bullet_spread_hor: int = config[2]
	var bullet_spread_ver: int = config[3]
	var bloom_hor: float = config[4]
	var bloom_ver: float = config[5]
	for _x in range(bullet_spread_hor):
		for _y in range(bullet_spread_ver):
			var bloom_y: float = deg_to_rad(calc_bloom(bloom_hor, bullet_spread_hor, _x))
			var bloom_x: float = deg_to_rad(calc_bloom(bloom_ver, bullet_spread_ver, _y))
			spawn_projectile.rpc(pos, get_what_look_at(), [config[0], bloom_x, bloom_y])
	shoot_animation.rpc()

func calc_bloom(bloom: float, proj_amount: int, i) -> float:
	var bloom_inc: float = float(bloom * 2) / float(proj_amount)
	var lower_bloom: float = (-bloom) + bloom_inc * i
	var upper_bloom: float = (-bloom) + bloom_inc * (i + 1)
	#return rng.randf_range(lower_bloom, upper_bloom)
	return (lower_bloom + upper_bloom) / 2
	
func get_what_look_at() -> Vector3:
	# if point to shoot at is too close bullets will go to the side | if point isn't in raycast
	if camera_cast.get_collider():
		if position.distance_to(camera_cast.get_collision_point()) > 2:
			return camera_cast.get_collision_point()
	var forward_direction: Vector3 = -camera_cast.global_transform.basis.z.normalized()
	return camera_cast.global_transform.origin + forward_direction * 100
	
func scale_marker(distance: float) -> void:
	var max_distance: float = 15.0
	var marker_scale: float = 1.0
	if distance > max_distance:
		marker_scale = distance/max_distance
		marker.scale = Vector3(marker_scale, marker_scale, marker_scale)
	else:
		marker.scale = Vector3(marker_scale, marker_scale, marker_scale)
