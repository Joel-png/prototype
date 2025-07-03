extends Holdable
class_name Grimoire

var total_damage_multiplier = 1.0
var total_percent_multiplier = 1.0
var total_projectiles = 1.0
var total_cast_cost = 0.0
var action_types = {
	"damage_multiplier": func(fish_data): do_damage_multiplier(fish_data["damage_multiplier"]),
	"damage_projectile": func(fish_data): do_damage_projectile(fish_data["damage"], fish_data["damage_projectile"]),
	"cast_cost": func(fish_data): do_cast_cost(fish_data["cast_cost"])
}

@onready var fish_manager = $FishManager

var equipped_fish = ["Beta fish", "Test fish"]

func _ready() -> void:
	pass
	

func action(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		compute_fishes("cast")
		

func reset_variables():
	total_damage_multiplier = 1.0
	total_percent_multiplier = 1.0
	total_projectiles = 1.0
	total_cast_cost = 0.0

func compute_fishes(proc_type: String):
	reset_variables()
	for fish_name in equipped_fish:
		print(fish_manager.cast_fish(fish_name, proc_type))
		compute_fish(fish_manager.cast_fish(fish_name, proc_type))
		
func compute_fish(variables):
	var _dictionary = variables[0]
	var _variable_types = variables[1]
	for i in range(0, _variable_types.size()):
		if action_types.has(_variable_types[i]):
			action_types[_variable_types[i]].call(_dictionary)

func do_damage_multiplier(damage_multiplier):
	total_damage_multiplier *= damage_multiplier

func do_damage(damage):
	return damage * total_damage_multiplier
	
func do_damage_projectile(damage, projectile_count):
	var calced_damage = do_damage(damage)
	spawn_projectile_test.rpc(calced_damage, projectile_count)

func do_cast_cost(cast_cost):
	total_cast_cost += cast_cost

@rpc("any_peer", "call_local")
func spawn_projectile_test(damage, projectile_count):
	print("spawn proj" + str(damage) + str(projectile_count))
