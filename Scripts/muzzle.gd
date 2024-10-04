extends Node3D

@onready var flasher = $GPUParticles3D
@onready var animation_player = $AnimationPlayer

func flash():
	flasher.restart()
	animation_player.play("flash")
