class_name SpawnAreaEnemiesProperty
extends EditorProperty


## Path to the enemy characters folder.
const ENEMY_CHARACTERS_PATH := "res://character/enemy_characters/"

## The overall container for the UI elements.
var _parent_container := VBoxContainer.new()
## The spin box for defining the number of enemy options.
var _size_spin := SpinBox.new()
## The container for the UI elements of the current enemy selection.
var _selection_container := VBoxContainer.new()
## The items within the selection container.
var _selection_items: Array[SelectionItem] = []
## The currently selected enemies.
var _selected_enemies: PackedStringArray = []
## The index of the item to delete.
var _deletion_index := -1
## Guard against internal changes when the property is updated.
var _updating := false

## The available enemy options.
static var enemy_options: PackedStringArray = []


## Creates the inspector controls.
func _init() -> void:
	var fold_container := FoldableContainer.new()
	fold_container.title_text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	fold_container.title = "Current Selection"
	add_child(fold_container)
	fold_container.add_child(_parent_container)
	_init_size_spinner()
	_parent_container.add_child(_selection_container)
	_init_plus_one_button()


## Updates the display to match the changes.
func _update_property() -> void:
	_selected_enemies = get_edited_object()[get_edited_property()].duplicate()
	_size_spin.set_value_no_signal(_selected_enemies.size())
	_update_selection_display()
	_deletion_index = -1


## Create a spinner for changing the number of options 
func _init_size_spinner() -> void:
	var spin_label := Label.new()
	var h_box := HBoxContainer.new()
	_parent_container.add_child(h_box)
	h_box.add_child(spin_label)
	spin_label.text = "Size:"
	h_box.add_child(_size_spin)
	_size_spin.step = 1.0
	_size_spin.value_changed.connect(_update_enemy_count)


## Create a button that adds one more item.
func _init_plus_one_button() -> void:
	var button := Button.new()
	_parent_container.add_child(button)
	button.text = "+ Add Enemy"
	button.pressed.connect(_increment_by_one)


## Update the UI display for selected enemies.
func _update_selection_display() -> void:
	var container_count := _selection_container.get_child_count()
	var selection_count := _selected_enemies.size()
	_updating = true
	if container_count < selection_count:
		for i: int in selection_count - container_count:
			var index := i + container_count
			_add_selection_item(_selected_enemies[index])
			# Set selected enemy value to default option value.
			_selected_enemies[index] = _selection_items[index].get_selection_text()
		emit_changed(get_edited_property(), _selected_enemies)
	elif _deletion_index >= 0:
		var item := _selection_items.pop_at(_deletion_index)
		_selection_container.remove_child(item.h_box)
		item.h_box.queue_free()
		# Update indexes to account for removed item.
		for i: int in _selection_items.size():
			_selection_items[i].index = i
	elif selection_count < container_count:
		for i: int in container_count - selection_count:
			var item := _selection_items.pop_back()
			_selection_container.remove_child(item.h_box)
			item.h_box.queue_free()
	else:
		for i: int in selection_count:
			_selection_items[i].update_option_selection(_selected_enemies[i])
	_updating = false


## Creates an interface for another selection item.
func _add_selection_item(selected_item: String) -> void:
	_get_enemy_options()
	var new_item := SelectionItem.new(_selection_container, selected_item)
	_selection_items.append(new_item)
	new_item.option_updated.connect(_update_enemy_option)
	new_item.option_removed.connect(_remove_enemy_option)


## Obtains the currently available enemy options from the file system.
func _get_enemy_options() -> void:
	enemy_options.clear()
	var enemy_folders := DirAccess.get_directories_at(ENEMY_CHARACTERS_PATH)
	for name: String in enemy_folders:
		enemy_options.append(name)
	for item: SelectionItem in _selection_items:
		item.match_current_enemy_options()


## Increases the size of the selection array by one.
func _increment_by_one() -> void:
	if _updating:
		return
	_selected_enemies.resize(_selected_enemies.size() + 1)
	emit_changed(get_edited_property(), _selected_enemies)


## Updates the size of the selection array to match the new count.
func _update_enemy_count(new_count: float) -> void:
	if _updating:
		return
	_selected_enemies.resize(int(new_count))
	emit_changed(get_edited_property(), _selected_enemies)


## Updates the selected option for a given index.
func _update_enemy_option(index: int, value: String) -> void:
	if _updating:
		return
	_selected_enemies[index] = value
	emit_changed(get_edited_property(), _selected_enemies)


## Removed the selection option at the given index.
func _remove_enemy_option(index: int) -> void:
	if _updating:
		return
	_deletion_index = index
	_selected_enemies.remove_at(index)
	emit_changed(get_edited_property(), _selected_enemies)


class SelectionItem:
## A UI element that represents a single selection option.
	
	
	signal option_updated(i, value)
	signal option_removed(i)
	
	var h_box: HBoxContainer
	var option_button: OptionButton
	var delete_button: Button
	var index: int
	
	
	## Creates a new item to add to the selection container.
	func _init(selection_container: Node, initial_value: String) -> void:
		index = selection_container.get_child_count()
		h_box = HBoxContainer.new()
		selection_container.add_child(h_box)
		_init_option_button(initial_value)
		delete_button = Button.new()
		h_box.add_child(delete_button)
		delete_button.text = "Delete"
		delete_button.pressed.connect(_indicate_removal)
	
	
	## Updates the option button to reflect the current enemy options.
	func match_current_enemy_options() -> void:
		var prior_selected := option_button.get_item_text(option_button.selected)
		option_button.clear()
		for option: String in SpawnAreaEnemiesProperty.enemy_options:
			option_button.add_item(option)
			if option == prior_selected:
				option_button.select(option_button.item_count - 1)
	
	
	## Gets the text of the currently selected option.
	func get_selection_text() -> String:
		return option_button.get_item_text(option_button.selected)
	
	
	## Updates the option button to reflect the selection.
	func update_option_selection(selection: String) -> void:
		var index := SpawnAreaEnemiesProperty.enemy_options.find(selection)
		option_button.select(0 if index < 0 else index)
	
	
	## Initializes the option button.
	func _init_option_button(initial_value: String) -> void:
		option_button = OptionButton.new()
		h_box.add_child(option_button)
		option_button.item_selected.connect(_indicate_update)
		var initial_index := 0
		for i: int in SpawnAreaEnemiesProperty.enemy_options.size():
			var option := SpawnAreaEnemiesProperty.enemy_options[i]
			option_button.add_item(option)
			if initial_value == option:
				initial_index = i
		option_button.select(initial_index)
	
	
	## Emits a signal indicating that this item has been updated.
	func _indicate_update(i: int) -> void:
		option_updated.emit(index, option_button.get_item_text(i))
	
	
	## Emits a signal indicating that this item is to be removed.
	func _indicate_removal() -> void:
		option_removed.emit(index)
