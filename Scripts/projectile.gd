extends RigidBody3D

var shoot = true
var speed = 1.0
var damage = 5.0

@onready var mesh = $MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _setup(start_pos, angle):
	position = start_pos
	rotation = angle


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shoot:
		apply_impulse(-transform.basis.z, transform.basis.z)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Hittable"):
		body.health -= damage
		queue_free()
	else:
		queue_free()
