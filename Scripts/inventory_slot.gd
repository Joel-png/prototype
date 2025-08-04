extends Panel

@onready var inventory = $"../../.."
@onready var item_texture = $PanelContainer/ItemTexture

var entered = false
var item
var is_backpack = true

func _on_mouse_entered() -> void:
	entered = true
	inventory.hover(self)

func _on_mouse_exited() -> void:
	entered = false
	inventory.unhover()

func set_item(new_item):
	item = new_item

func update_item():
	if item != null:
		item_texture.texture = item.image
	else:
		item_texture.texture = null

func get_description():
	if item != null:
		return item.fish_name + "\n" + item.description.format(item.variables)
	else:
		return null

func remove_item():
	item = null

func get_fish_name():
	if item != null:
		return item.fish_name
	else:
		return "null"
