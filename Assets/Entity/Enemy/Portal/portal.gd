extends Node3D

var time_scale = 0.1

func _process(_delta):
	rotate_pivot()

func rotate_pivot():
	var passing_time = Time.get_ticks_msec() / 1000.0 * time_scale
	
	$Node3D/RingPivot.rotation = Vector3(TAU * passing_time, TAU * passing_time * 0.66, 0)
	passing_time += 1
	$Node3D/RingPivot2.rotation = Vector3(0, TAU * passing_time * -1.25, TAU * passing_time * 0.5)
	passing_time += 1
	$Node3D/RingPivot3.rotation = Vector3(TAU * passing_time * 0.75, 0, TAU * passing_time * -1.33)
