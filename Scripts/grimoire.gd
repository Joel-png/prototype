extends Holdable
class_name Grimoire

var total_damage_multiplier = 1.0
var total_percent_multiplier = 1.0
var total_projectiles = 0.0
var total_cast_cost = 0.0
var action_types = {
	"damage_multiplier": func(fish_data): do_damage_multiplier(fish_data["damage_multiplier"]),
	"percent_multiplier": func(fish_data): do_percent_multiplier(fish_data["percent_multiplier"]),
	"projectile_add": func(fish_data): do_projectile_add(fish_data["projectile_add"]),
	"buff": func(fish_data): do_damage_multiplier(fish_data),
	"spell": func(fish_data): do_damage_projectile(fish_data),
	"cast_cost": func(fish_data): do_cast_cost(fish_data["cast_cost"])
}

@onready var fish_manager = get_tree().get_nodes_in_group("FishManager")[0]

var equipped_fish = []

func _ready() -> void:
	pass
	

func action(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		compute_fishes("cast")
		

func reset_variables():
	total_damage_multiplier = 1.0
	total_percent_multiplier = 1.0
	total_projectiles = 0.0
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

func do_percent_multiplier(percent_multiplier):
	total_percent_multiplier *= percent_multiplier

func do_projectile_add(projectile_add):
	total_projectiles += projectile_add

func do_percent(percent):
	return percent * total_percent_multiplier

func do_damage(damage):
	return damage * total_damage_multiplier

func do_projectile(projectile):
	return projectile + total_projectiles

func do_damage_projectile(fish_data):
	var calced_damage = do_damage(fish_data["damage"])
	var calced_projectile = do_projectile(fish_data["projectile"])
	spawn_projectile_test.rpc(fish_data["spell"], calced_damage, calced_projectile, total_cast_cost)

func do_cast_cost(cast_cost):
	total_cast_cost += cast_cost

@rpc("any_peer", "call_local")
func spawn_projectile_test(spell_type, damage, projectile_count, cast_cost):
	print("spawn proj" + spell_type + " " + str(damage) + " " + str(projectile_count) + " " + str(cast_cost))
