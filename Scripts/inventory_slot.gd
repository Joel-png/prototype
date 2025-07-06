extends Panel

@onready var inventory = $"../../.."
@onready var item_texture = $ItemTexture
var entered = false
var item

func _on_mouse_entered() -> void:
	entered = true
	inventory.hover(self)

func _on_mouse_exited() -> void:
	entered = false

func set_item(new_item):
	item = new_item

func update_item():
	if item != null:
		item_texture.texture = item.image
	else:
		item_texture.texture = null

func remove_item():
	item = null

func get_fish_name():
	if item != null:
		return item.fish_name
	else:
		return "null"
