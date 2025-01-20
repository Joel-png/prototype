extends Holdable
class_name Rod

var base_action_cooldown: float = 1
var action_cooldown: float = 1
var cast_speed: float = 2.0
var rotation_amount = deg_to_rad(45)
var starting_rot_x = rotation.x
var casting = false

func _ready() -> void:
	pass
	

func action(delta: float) -> void:
	if Input.is_action_pressed("left_click") and not casting:
		action_cooldown -= delta
	else:
		if action_cooldown < 0:
			casting = true
		if action_cooldown < base_action_cooldown:
			action_cooldown += base_action_cooldown * cast_speed * delta
			if action_cooldown > base_action_cooldown:
				action_cooldown = base_action_cooldown
				casting = false
		
	rotation.x = starting_rot_x + rotation_amount * (1 - action_cooldown)
