tool
extends MarginContainer
"""
Manages the label and icon settings of an OptionButton for encounters.
"""


signal button_state_changed(state)

enum ButtonStates {
	BUTTON_DOWN,
	BUTTON_UP,
	FOCUS_ENTERED,
	FOCUS_EXITED,
	MOUSE_ENTERED,
	MOUSE_EXITED,
}

export(String) var label setget set_label, get_label
export(Texture) var icon_normal = null setget set_icon_normal, get_icon_normal
export(Texture) var icon_pressed = null setget set_icon_pressed, get_icon_pressed
export(Texture) var icon_hover = null setget set_icon_hover, get_icon_hover
export(Texture) var icon_disabled = null setget set_icon_disabled, get_icon_disabled
export(Texture) var icon_focused = null setget set_icon_focused, get_icon_focused
export(bool) var disabled = false

var is_highlighted: bool

onready var button: Button = $Button
onready var label_node: Label = $VBoxContainer/Label
onready var icon_node: TextureRect = $VBoxContainer/Icon


# Called when the node enters the scene tree for the first time.
func _ready():
	is_highlighted = true
	if label != null:
		label_node.text = label


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if disabled:
		icon_node.texture = (
				icon_disabled if icon_disabled != null
				else icon_normal
		)
		label_node.modulate.a8 = 100
		button.disabled = true
	else:
		icon_node.texture = (
				icon_normal if icon_node.texture == icon_disabled 
				else icon_node.texture
		)
		label_node.modulate.a8 = (
				255 if label_node.modulate.a8 < 255 
				else label_node.modulate.a8
		)
		button.disabled = false


# Sets the text value of the `Label` node of the `OptionButton` scene.
func set_label(new_label: String):
	if label != new_label:
		label = new_label
		if is_node_ready():
			label_node.text = new_label


# Get the current text value for `Label`.
func get_label() -> String:
	return label_node.text if label_node.text != null else ""


# Sets the "normal" texture for the `Icon` node.
func set_icon_normal(new_icon_normal: Texture):
	if icon_normal != new_icon_normal:
		# Set the default to the Godot icon
		icon_normal = (
				new_icon_normal
				if new_icon_normal != null
				else load(Constants.DEFAULT_ICON_PATH)
		)
		if is_node_ready():
			icon_node.texture = icon_normal


# Gets the current "normal" texture for the `Icon` node.
func get_icon_normal() -> Texture:
	return (
			icon_normal if icon_normal != null 
			else load(Constants.DEFAULT_ICON_PATH)
	)


# Sets the "pressed" texture for the `Icon` node.
func set_icon_pressed(new_icon_pressed: Texture):
	if icon_pressed != new_icon_pressed:
		icon_pressed = new_icon_pressed


# Gets the current "pressed" texture for the `Icon` node.
func get_icon_pressed() -> Texture:
	return icon_pressed


# Sets the "hover" texture for the `Icon` node.
func set_icon_hover(new_icon_hover: Texture):
	if icon_hover != new_icon_hover:
		icon_hover = new_icon_hover


# Gets the current "hover" texture for the `Icon` node.
func get_icon_hover() -> Texture:
	return icon_hover


# Sets the "disabled" texture for the `Icon` node.
func set_icon_disabled(new_icon_disabled: Texture):
	if icon_disabled != new_icon_disabled:
		icon_disabled = new_icon_disabled


# Gets the current "disabled" texture for the `Icon` node.
func get_icon_disabled() -> Texture:
	return icon_disabled


# Sets the "focused" texture for the `Icon` node.
func set_icon_focused(new_icon_focused: Texture):
	if icon_focused != new_icon_focused:
		icon_focused = new_icon_focused


# Gets the current "focused" texture for the `Icon` node.
func get_icon_focused() -> Texture:
	return icon_focused


# Update the `Icon` to "pressed" when the button is depressed.
func _on_Button_button_down():
	icon_node.texture = icon_pressed if icon_pressed != null else icon_normal
	emit_signal("button_state_changed", ButtonStates.BUTTON_DOWN)


# Update the `Icon` to "normal" when the button is released.
func _on_Button_button_up():
	icon_node.texture = (
			icon_hover if icon_hover != null and is_highlighted 
			else icon_normal
	)
	emit_signal("button_state_changed", ButtonStates.BUTTON_UP)


# Update the `Icon` to "focused" when the button gains focus.
func _on_Button_focus_entered():
	icon_node.texture = icon_focused if icon_focused != null else icon_normal
	emit_signal("button_state_changed", ButtonStates.FOCUS_ENTERED)


# Update the `Icon` to "normal" when the button loses focus.
func _on_Button_focus_exited():
	icon_node.texture = (
			icon_hover if icon_hover != null and is_highlighted
			else icon_normal
	)
	emit_signal("button_state_changed", ButtonStates.FOCUS_EXITED)


# Update the `Icon` to "hover" when the button is hovered over by the mouse.
func _on_Button_mouse_entered():
	is_highlighted = true
	icon_node.texture = icon_hover if icon_hover != null else icon_normal
	emit_signal("button_state_changed", ButtonStates.MOUSE_ENTERED)


# Update the `Icon` to "normal" when the button is no longer hovered over by the mouse.
func _on_Button_mouse_exited():
	is_highlighted = false
	icon_node.texture = icon_normal
	emit_signal("button_state_changed", ButtonStates.MOUSE_EXITED)
