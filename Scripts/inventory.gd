extends Control

var total_inventory: Array
var hovered_slot = null
var first_slot
var second_slot
var grabbing = false
var inventory_page_size = 0
@onready var inventory_manager = $".."
@onready var inventory_slots = $CenterContainer2/InventoryGrid.get_children()
@onready var fish_slots = $CenterContainer/InventoryGrid
@onready var fish_manager = get_tree().get_nodes_in_group("FishManager")[0]

func _ready() -> void:
	call_deferred("_late_ready")

func _late_ready() -> void:
	total_inventory.append(fish_manager.get_new_fish_from_name("Test fish"))
	total_inventory.append(fish_manager.get_new_fish_from_name("Beta fish"))
	total_inventory.append(fish_manager.get_new_fish_from_name("Beta fish"))
	total_inventory.append(fish_manager.get_new_fish_from_name("Beta fish"))
	update_inventory_display_page(0)

func _process(delta: float) -> void:
	if not grabbing:
		grab()
	elif grabbing:
		hold()

func update_inventory_display_page(page_number: int):
	inventory_page_size = inventory_slots.size()
	if total_inventory.size() > inventory_page_size * page_number:
		for i in range(0, inventory_slots.size()):
			if total_inventory.size() < i + inventory_page_size * page_number:
				break
			inventory_slots[i].set_item(total_inventory[i + inventory_page_size * page_number])
	
	for slot in inventory_slots:
		slot.update_item()

func update_selected_fish():
	var slot_list = $CenterContainer/InventoryGrid.get_children()
	var valid_fish: Array = []
	for slot in slot_list:
		if slot.get_fish_name() != "null":
			valid_fish.append(slot.item)
	print(valid_fish.size())
	return valid_fish

func grab():
	if Input.is_action_just_pressed("left_click"):
		if hovered_slot != null:
			if hovered_slot.entered:
				first_slot = hovered_slot
				grabbing = true

func hold():
	if Input.is_action_just_released("left_click"):
		if hovered_slot != null:
			if hovered_slot.entered:
				second_slot = hovered_slot
				grabbing = false
				swap_items(first_slot, second_slot)

func swap_items(first, second):
	if first != second:
		print("swapping " + first.get_fish_name() + " " + second.get_fish_name())
		var temp_item = first.item
		first.item = second.item
		second.item = temp_item
		first.update_item()
		second.update_item()
		inventory_manager.update_grimoire_fish(update_selected_fish())

func hover(slot):
	hovered_slot = slot
