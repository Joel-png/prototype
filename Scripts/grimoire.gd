extends Holdable
class_name Grimoire

var damage_multiplier = 1.0
var percent_multiplier = 1.0

@onready var fish_manager = $FishManager

var equipped_fish = ["Beta fish", "Test fish"]

func _ready() -> void:
	pass
	

func action(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		compute_fish()
		

func compute_fish():
	for fish_name in equipped_fish:
		print(fish_manager.cast_fish(fish_name))
	
