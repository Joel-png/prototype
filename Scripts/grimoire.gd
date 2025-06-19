extends Holdable
class_name Grimoire

var base_action_cooldown: float = 1
var action_cooldown: float = 1
var cast_speed: float = 2.0
var rotation_amount = deg_to_rad(45)
var starting_rot_x = rotation.x
var casting = false

var equipped_fish = []

func _ready() -> void:
	pass
	

func action(_delta: float) -> void:
	pass
	
