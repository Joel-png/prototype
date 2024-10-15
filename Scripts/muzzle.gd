extends Node3D

@onready var flasher = $GPUParticles3D
@onready var animation_player = $AnimationPlayer

func flash() -> void:
	flasher.restart()
	animation_player.play("flash")
