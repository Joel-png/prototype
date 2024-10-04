extends Node3D

@onready var flasher = $GPUParticles3D

func flash():
	flasher.restart()
	flasher.emitting = true
	
