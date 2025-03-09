tool
class_name LabeledIconButton
extends MarginContainer
"""
Manages the label and icon settings of an OptionButton for encounters.
"""


export(String) var label setget set_label, get_label
export(Texture) var icon_normal = null setget set_icon_normal, get_icon_normal
export(Texture) var icon_pressed = null setget set_icon_pressed, get_icon_pressed
export(Texture) var icon_hover = null setget set_icon_hover, get_icon_hover
export(Texture) var icon_disabled = null setget set_icon_disabled, get_icon_disabled
export(Texture) var icon_focused = null setget set_icon_focused, get_icon_focused
export(bool) var disabled = false setget set_disabled, get_disabled

var _is_highlighted: bool

onready var _button: Button = $Button
onready var _label_node: Label = $VBoxContainer/Label
onready var _icon_node: TextureRect = $VBoxContainer/Icon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_is_highlighted = true
	if label != null:
		_label_node.text = label
	_disabled_update()


# Sets the text value of the `Label` node of the `OptionButton` scene.
func set_label(new_label: String) -> void:
	label = new_label
	if is_node_ready():
		_label_node.text = new_label


# Get the current text value for `Label`.
func get_label() -> String:
	return _label_node.text if _label_node != null else ""


# Sets the "normal" texture for the `Icon` node.
func set_icon_normal(new_icon_normal: Texture) -> void:
	# Set the default to the Godot icon
	icon_normal = (
			new_icon_normal
			if new_icon_normal != null
			else load(Constants.DEFAULT_ICON_PATH)
	)
	if is_node_ready():
		_icon_node.texture = icon_normal


# Gets the current "normal" texture for the `Icon` node.
func get_icon_normal() -> Texture:
	return (
			icon_normal if icon_normal != null 
			else load(Constants.DEFAULT_ICON_PATH)
	)


# Sets the "pressed" texture for the `Icon` node.
func set_icon_pressed(new_icon_pressed: Texture) -> void:
	icon_pressed = new_icon_pressed


# Gets the current "pressed" texture for the `Icon` node.
func get_icon_pressed() -> Texture:
	return icon_pressed


# Sets the "hover" texture for the `Icon` node.
func set_icon_hover(new_icon_hover: Texture) -> void:
	icon_hover = new_icon_hover


# Gets the current "hover" texture for the `Icon` node.
func get_icon_hover() -> Texture:
	return icon_hover


# Sets the "disabled" texture for the `Icon` node.
func set_icon_disabled(new_icon_disabled: Texture) -> void:
	icon_disabled = new_icon_disabled


# Gets the current "disabled" texture for the `Icon` node.
func get_icon_disabled() -> Texture:
	return icon_disabled


# Sets the "focused" texture for the `Icon` node.
func set_icon_focused(new_icon_focused: Texture) -> void:
	icon_focused = new_icon_focused


# Gets the current "focused" texture for the `Icon` node.
func get_icon_focused() -> Texture:
	return icon_focused


# Set the disabled flag.
func set_disabled(flag_value: bool) -> void:
	disabled = flag_value
	_disabled_update()


# Get the disabled flag.
func get_disabled() -> bool:
	return disabled


# Connects the specified signal of this node's button to the function of the
# connecting node.
func connect_button_signal(
	connecting_node: Node, 
	signal_to_connect: String,
	function_name: String
) -> void:
	ErrorUtil.connect_signal(
		_button,
		signal_to_connect,
		connecting_node,
		function_name
	)


# Disconnects the specified signal of this node's button from the function of the
# connecting node.
func disconnect_button_signal(
	connecting_node: Node, 
	signal_to_disconnect: String,
	function_name: String
) -> void:
	_button.disconnect(signal_to_disconnect, connecting_node, function_name)


# Update the button based on the disabled flag
func _disabled_update() -> void:
	if disabled:
		_icon_node.texture = (
				icon_disabled if icon_disabled != null
				else icon_normal
		)
		_label_node.modulate.a8 = 100 # Fade the button text
		_button.disabled = true
	else:
		_icon_node.texture = (
				icon_normal if _icon_node.texture == icon_disabled 
				else _icon_node.texture
		)
		# Restore the button text opacity
		_label_node.modulate.a8 = (
				255 if _label_node.modulate.a8 < 255 
				else _label_node.modulate.a8
		)
		_button.disabled = false


# Update the `Icon` to "pressed" when the button is depressed.
func _on_Button_button_down() -> void:
	if not disabled:
		_icon_node.texture = icon_pressed if icon_pressed != null else icon_normal


# Update the `Icon` to "normal" when the button is released.
func _on_Button_button_up() -> void:
	if not disabled:
		_icon_node.texture = (
				icon_hover if icon_hover != null and _is_highlighted 
				else icon_normal
		)


# Update the `Icon` to "focused" when the button gains focus.
func _on_Button_focus_entered() -> void:
	if not disabled:
		_icon_node.texture = icon_focused if icon_focused != null else icon_normal


# Update the `Icon` to "normal" when the button loses focus.
func _on_Button_focus_exited() -> void:
	if not disabled:
		_icon_node.texture = (
				icon_hover if icon_hover != null and _is_highlighted
				else icon_normal
		)


# Update the `Icon` to "hover" when the button is hovered over by the mouse.
func _on_Button_mouse_entered() -> void:
	if not disabled:
		_is_highlighted = true
		_icon_node.texture = icon_hover if icon_hover != null else icon_normal


# Update the `Icon` to "normal" when the button is no longer hovered over by the mouse.
func _on_Button_mouse_exited() -> void:
	if not disabled:
		_is_highlighted = false
		_icon_node.texture = icon_normal
