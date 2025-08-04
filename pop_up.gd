extends Control


@onready var label = $PanelContainer/MarginContainer/Label
@onready var container = $PanelContainer
var position_offset: Vector2 = Vector2.ZERO

func _process(_delta: float):
	update_position_offset()
	var mouse_pos = get_viewport().get_mouse_position()
	position = mouse_pos - position_offset

func update_popup_text(text: String):
	label.text = text

func update_position_offset():
	var container_size = container.size
	position_offset = Vector2(container_size.x / 2 / scale.x, container_size.y / scale.y)
