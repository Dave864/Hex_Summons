class_name DisplayPanel
extends PanelContainer
"""
Panel for displaying a picture with text below it.
"""


export(String) var text = "" setget set_text, get_text
export(Texture) var image = null setget set_image, get_image


func set_text(t: String) -> void:
	text = t
	$VBoxContainer/Text.text = text


func get_text() -> String:
	return text


func set_image(new_image: Texture) -> void:
	image = new_image if new_image != null else load(Constants.DEFAULT_ICON_PATH)
	$VBoxContainer/Image.texture = image


func get_image() -> Texture:
	return image


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
