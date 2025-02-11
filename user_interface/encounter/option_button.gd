tool
extends MarginContainer
"""
Manages the label and icon setting of an OptionButton for encounters.
"""


export(String) var label setget set_label, get_label
export(Texture) var icon setget set_icon_texture, get_icon_texture

onready var button: Button = $Button
onready var label_node: Label = $VBoxContainer/Label
onready var icon_node: TextureRect = $VBoxContainer/Icon


# Called when the node enters the scene tree for the first time.
func _ready():
	if label != null:
		label_node.text = label
	if icon != null:
		icon_node.texture = icon


# Sets the text value of the `Label` node of the `OptionButton` scene.
func set_label(new_label: String):
	if label != new_label:
		label = new_label
		if is_node_ready():
			label_node.text = new_label


# Get the current text value for `Label`.
func get_label() -> String:
	return label_node.text if label_node.text != null else ""


# Sets the icon image of the `Icon` node to the specified texture.
# Defaults to a placeholder if no texture is given.
func set_icon_texture(new_icon: Texture):
	if icon != new_icon:
		icon = new_icon
		if is_node_ready():
			icon_node.texture = new_icon


# Get the current texture for `Icon`.
func get_icon_texture() -> Texture:
	return icon_node.texture
