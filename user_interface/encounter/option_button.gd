tool
extends MarginContainer
"""
Manages the label and icon setting of an OptionButton for encounters.
"""


export(String) var label setget set_label, get_label
export(Texture) var icon_normal = null setget set_icon_normal, get_icon_normal
export(Texture) var icon_pressed = null setget set_icon_pressed, get_icon_pressed
export(Texture) var icon_hover = null setget set_icon_hover, get_icon_hover
export(Texture) var icon_disabled = null setget set_icon_disabled, get_icon_disabled
export(Texture) var icon_focused = null setget set_icon_focused, get_icon_focused
export(BitMap) var icon_click_mask = null setget set_icon_click_mask, get_icon_click_mask

onready var button: Button = $Button
onready var label_node: Label = $VBoxContainer/Label
onready var icon_node: TextureButton = $VBoxContainer/Icon


# Called when the node enters the scene tree for the first time.
func _ready():
	if label != null:
		label_node.text = label
	if icon_normal != null:
		icon_node.texture_normal = icon_normal
	if icon_pressed != null:
		icon_node.texture_pressed = icon_pressed
	if icon_hover != null:
		icon_node.texture_hover = icon_hover
	if icon_disabled != null:
		icon_node.texture_disabled = icon_disabled
	if icon_focused != null:
		icon_node.texture_focused = icon_focused
	if icon_click_mask != null:
		icon_node.texture_click_mask = icon_click_mask


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
			icon_node.texture_normal = icon_normal


# Gets the current "normal" texture for the `Icon` node.
func get_icon_normal() -> Texture:
	return icon_node.texture_normal


# Sets the "pressed" texture for the `Icon` node.
func set_icon_pressed(new_icon_pressed: Texture):
	if icon_pressed != new_icon_pressed:
		icon_pressed = new_icon_pressed
		if is_node_ready():
			icon_node.texture_pressed = icon_pressed


# Gets the current "pressed" texture for the `Icon` node.
func get_icon_pressed() -> Texture:
	return icon_node.texture_pressed


# Sets the "hover" texture for the `Icon` node.
func set_icon_hover(new_icon_hover: Texture):
	if icon_hover != new_icon_hover:
		icon_hover = new_icon_hover
		if is_node_ready():
			icon_node.texture_hover = icon_hover


# Gets the current "hover" texture for the `Icon` node.
func get_icon_hover() -> Texture:
	return icon_node.texture_hover


# Sets the "disabled" texture for the `Icon` node.
func set_icon_disabled(new_icon_disabled: Texture):
	if icon_disabled != new_icon_disabled:
		icon_disabled = new_icon_disabled
		if is_node_ready():
			icon_node.texture_disabled = icon_disabled


# Gets the current "disabled" texture for the `Icon` node.
func get_icon_disabled() -> Texture:
	return icon_node.texture_disabled


# Sets the "focused" texture for the `Icon` node.
func set_icon_focused(new_icon_focused: Texture):
	if icon_focused != new_icon_focused:
		icon_focused = new_icon_focused
		if is_node_ready():
			icon_node.texture_focused = icon_focused


# Gets the current "focused" texture for the `Icon` node.
func get_icon_focused() -> Texture:
	return icon_node.texture_focused


# Sets the "click mask" texture for the `Icon` node.
func set_icon_click_mask(new_icon_click_mask: BitMap):
	if icon_click_mask != new_icon_click_mask:
		icon_click_mask = new_icon_click_mask
		if is_node_ready():
			icon_node.texture_click_mask = icon_click_mask


# Gets the current "click mask" texture for the `Icon` node.
func get_icon_click_mask() -> BitMap:
	return icon_node.texture_click_mask
