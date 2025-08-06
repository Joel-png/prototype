extends Node3D

# tokens dictate the bias of spawn weights
var spawn_tokens = 200
var enemy_spawn_weights: Array[float]
var enemy_data = {
	"scuttler": 25,
	"azathoth": 100
}
var enemy_cost: Array[int]

func _ready() -> void:
	for key in enemy_data.keys():
		enemy_cost.append(enemy_data[key])
	
	set_weights()
	set_weights()
	set_weights()
	set_weights()
	set_weights()

func set_weights():
	enemy_spawn_weights.resize(enemy_data.size())
	for i in range(0, enemy_spawn_weights.size()):
		enemy_spawn_weights[i] = 0
	var total_tokens = spawn_tokens
	var tokens_left = spawn_tokens * randf_range(0.5, 2.0)
	var enemy_set: Array[bool]
	for i in range(0, enemy_data.size()):
		enemy_set.append(false)
	
	#while tokens_left > 25:
	for i in range(0, 5):
		var j = randi_range(0, enemy_cost.size() - 1)
		var current_enemy_cost = enemy_cost[j]
		if current_enemy_cost <= spawn_tokens:
			var weight_from_tokens = ceil(max(0.1, current_enemy_cost/total_tokens * randf_range(0.5, 10.0)))
			enemy_spawn_weights[j] += weight_from_tokens
	#fix this
	
	
	print("enemy spawner stuff")
	print(tokens_left)
	print(enemy_spawn_weights)


func pick_enemy():
	pass
