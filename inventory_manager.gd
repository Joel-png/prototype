extends Node3D

@onready var player = $"../../../../.."

func update_grimoire_fish(fish):
	$"HotbarContainer/Grimoire".equipped_fish = fish
