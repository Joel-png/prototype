extends Holdable
class_name Grimoire

var total_damage_multiplier = 1.0
var total_percent_multiplier = 1.0
var action_types = {
	"damage_multiplier": func(damage_multiplier): do_damage_multiplier(damage_multiplier),
	"damage_projectile": func(damage): do_damage_projectile(damage)
}

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
	
func do_damage_multiplier(damage_multiplier):
	total_damage_multiplier *= damage_multiplier

func do_damage(damage):
	return damage * total_damage_multiplier
	
func do_damage_projectile(damage):
	var calced_damage = do_damage(damage)
	spawn_projectile_test.rpc()
	
@rpc("any_peer", "call_local")
func spawn_projectile_test(damage):
	print("spawn proj" + str(damage))
