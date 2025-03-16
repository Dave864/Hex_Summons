class_name DisplayPanel
extends PanelContainer
"""
Panel for displaying a picture with text below it.
"""


export(String) var text = "" setget set_text, get_text
export(Texture) var image = null setget set_image, get_image



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_check_for_required_parameters()


# Set the text of the DisplayPanel.
func set_text(t: String) -> void:
	text = t
	$VBoxContainer/Text.text = text


# Get the text of the DisplayPanel.
func get_text() -> String:
	return text


# Sets the image of the DisplayPanel.
func set_image(new_image: Texture) -> void:
	image = new_image if new_image != null else load(Constants.DEFAULT_ICON_PATH)
	$VBoxContainer/Image.texture = image


# Get the image of the DisplayPanel.
func get_image() -> Texture:
	return image


# Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	var container_path: String = "VBoxContainer"
	var text_path: String = "VBoxContainer/Text"
	var image_path: String = "VBoxContainer/Image"
	assert(
			get_node_or_null(container_path) != null,
			"DisplayPanel does not have a VBoxContainer to store the Text and Image nodes."
	)
	assert(
			get_node(container_path) is VBoxContainer,
			"DisplayPanel container for Text and Image nodes is not a VBoxContainer."
	)
	assert(
			get_node_or_null(text_path) != null,
			"DisplayPanel does not have a Text node."
	)
	assert(
			get_node(text_path) is Label,
			"DisplayPanel Text node is not a Label."
	)
	assert(
			get_node_or_null(image_path) != null,
			"DisplayPanel does not have an Image node."
	)
	assert(
			get_node(image_path) is TextureRect,
			"DisplayPanel Image node is not a TextureRect."
	)
