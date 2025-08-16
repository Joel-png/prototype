extends CharacterBody3D

var water_height 
var time_scale = 1.0
var bob_amount = 0.5
var hit_water: bool = false
var base_vel = 10.0
	
func _ready():
	call_deferred("_deferred_ready")
	hide()

func _deferred_ready():
	water_height = get_tree().get_nodes_in_group("World")[0].terrain_generator.water_height

func _process_hook(delta: float) -> void:
	if global_position.y >= water_height + sin(time_scale * Time.get_ticks_msec() * bob_amount):
		velocity.y -= 20.0 * delta
	else:
		hit_water = true
		velocity.y += 22.0 * delta
	
	velocity *= 1.0 - 0.99 * delta
	move_and_slide()

func cast(pos, rot, look_at_pos, vel):
	hit_water = false
	water_height = get_tree().get_nodes_in_group("World")[0].terrain_generator.water_height
	position = pos
	look_at(look_at_pos)
	var forward = -transform.basis.z
	velocity = forward * base_vel * vel
	rotation = rot
	show()
