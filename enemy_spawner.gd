extends Node3D

# tokens dictate the bias of spawn weights
var spawn_tokens = 100
var enemy_spawn_weights: Array[float]
var enemy_data = {
	"scuttler": 5,
	"azathoth": 100
}
var enemy_cost: Array[int]

func _ready() -> void:
	enemy_spawn_weights.resize(enemy_data.size())
	for key in enemy_data.keys():
		enemy_cost.append(enemy_data[key])
	
	set_weights()

func set_weights():
	var total_tokens = spawn_tokens
	var tokens_left = spawn_tokens
	var enemy_set: Array[bool]
	for i in range(0, enemy_data.size()):
		enemy_set.append(false)
	
	for i in range(enemy_cost.size() - 1, -1, -1):
		if not enemy_set[i]:
			var current_enemy_cost = enemy_cost[i]
			if tokens_left >= current_enemy_cost:
				var weight_from_tokens = total_tokens/current_enemy_cost
				enemy_spawn_weights[i] += weight_from_tokens
				tokens_left -= weight_from_tokens
				enemy_set[i] = true
	
	print("enemy spawner stuff")
	print(tokens_left)
	print(enemy_spawn_weights)


func pick_enemy():
	pass
