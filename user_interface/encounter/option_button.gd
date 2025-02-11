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
	pass # Replace with function body.


# Sets the text value of the `Label` node of the `OptionButton` scene.
func set_label(label_text: String):
	label_node.text = label_text


# Get the current text value for `Label`.
func get_label() -> String:
	return label_node.text if label_node.text != null else ""


# Sets the icon image of the `Icon` node to the specified texture.
# Defaults to a placeholder if no texture is given.
func set_icon_texture(icon_texture: Texture):
	icon_node.texture = icon_texture


# Get the current texture for `Icon`.
func get_icon_texture() -> Texture:
	return icon_node.texture
