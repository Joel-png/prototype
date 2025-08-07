extends Node3D

# tokens dictate the bias of spawn weights
var spawn_tokens = 111
var enemy_spawn_weights: Array[float]
var total_weights = 0
var enemy_data = {
	"scuttler": 5,
	"bazathoth": 10,
	"azathoth": 100
}
var enemy_data_keys = enemy_data.keys()

func _ready() -> void:
	set_weights()
	set_weights()
	set_weights()
	set_weights()
	set_weights()
	
	pick_enemy()
	pick_enemy()
	pick_enemy()


func set_tokens(tokens):
	spawn_tokens = tokens
	set_weights()

func set_weights():
	enemy_spawn_weights.resize(enemy_data.size())
	for i in range(0, enemy_spawn_weights.size()):
		enemy_spawn_weights[i] = 0
	var total_tokens = spawn_tokens
	var tokens_left = spawn_tokens * randf_range(0.5, 2.0)
	total_weights = 0
	
	#while tokens_left > 25:
	for i in range(0, 5):
		var j = randi_range(0, enemy_data.size() - 1)
		var current_enemy_cost = enemy_data_index(j)
		if current_enemy_cost <= tokens_left:
			var weight_from_tokens = ceil(max(0.1, pow(current_enemy_cost, 1.1) * randf_range(0.5, 10.0)))
			enemy_spawn_weights[j] += weight_from_tokens
			tokens_left -= current_enemy_cost
			total_weights += weight_from_tokens
	
	
	enemy_spawn_weights = [1, 1, 100]
	total_weights = 101
	print(enemy_spawn_weights)
	print(total_weights)


func pick_enemy():
	var random = randi_range(0, total_weights)
	print("picked")
	print(random)
	var current_weight = random
	
	var valid_enemy_index = -1
	for i in range(0, enemy_data.size()):
		if enemy_data_index(i) <= spawn_tokens and enemy_spawn_weights[i] > 0.0:
			valid_enemy_index = i
		if current_weight > enemy_spawn_weights[i]: # if we run out of tokens break
			current_weight -= enemy_spawn_weights[i]
		else:
			break
	
	if valid_enemy_index == -1:
		print("not enough")
		print(spawn_tokens)
		return null
	var enemy_picked = enemy_data_keys[valid_enemy_index]
	spawn_tokens -= enemy_data_index(valid_enemy_index)
	print(spawn_tokens)
	print(enemy_picked)
	return enemy_picked

func enemy_data_index(i):
	return enemy_data[enemy_data_keys[i]]
