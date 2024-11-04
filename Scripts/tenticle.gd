extends Node3D

@onready var mesh = $TenticleMesh
@onready var end_pivot = $TenticleMesh/EndPivot

@export var tenticle_material: Material
@export var length: int
@export var size_decrease: float = 0.75
@export var rotation_speed: Vector3 = Vector3(0.001, 0.001, 0.001)
@export var rotation_multiplier: Vector3 = Vector3(0.05, 0.4, 0.2)

var tenticle_scene = preload("res://Assets/Entity/Enemy/tenticle.tscn")
var segment_children: int = 0

var random_rotation_offset: Vector3 = Vector3(randf_range(-PI, PI), randf_range(-PI, PI), randf_range(-PI, PI))

var root_segment: bool = true
var base_rotation: Vector3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_rotation = rotation
	mesh.mesh.material = tenticle_material
	if root_segment:
		segment_children = length
	segment_children -= 1
	if segment_children > 0:
		create_tenticle_segments(segment_children)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var time: int = Time.get_ticks_msec()
	rotation.x = base_rotation.x + cos(float(time) * rotation_speed.x + random_rotation_offset.x) * rotation_multiplier.x
	rotation.y = base_rotation.y + sin(float(time) * rotation_speed.y + random_rotation_offset.y) * rotation_multiplier.y
	rotation.z = base_rotation.z + cos(float(time) * rotation_speed.z + random_rotation_offset.z) * rotation_multiplier.z

func create_tenticle_segments(segments: int):
	var segment = tenticle_scene.instantiate()
	segment.segment_children = segments
	segment.root_segment = false
	segment.size_decrease = size_decrease
	segment.rotation_speed = rotation_speed
	segment.rotation_multiplier = rotation_multiplier
	segment.tenticle_material = tenticle_material
	var size = size_decrease
	segment.scale = Vector3(size, 1, size)
	end_pivot.add_child(segment)
