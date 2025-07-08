extends Node3D

@onready var player = $"../../.."

func update_grimoire_fish(fish):
	$Grimoire.equipped_fish = fish
