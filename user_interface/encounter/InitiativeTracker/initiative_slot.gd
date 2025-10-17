class_name InitiativeSlot
extends TextureRect
"""
Displays the portrait, current health, and initiative slot of a given character.
"""


@onready var initiative: Label = $InitPanel/Initiative
@onready var portrait: TextureRect = $Portrait


# Updates the details of the slot to represent the new character
func change_character(c: Character) -> void:
	update_portrait(c.battle_portrait)
	if c is PlayerCharacter:
		material.set_shader_parameter("new_color", Color.AQUA)
	else:
		material.set_shader_parameter("new_color", Color.RED)


# Updates the portrait.
func update_portrait(new_p: Texture2D) -> void:
	portrait.texture = new_p
	# Need to use color as GDScript does not have a native Vector4.
	var region: Color = Color(0.0, 0.0, 0.0, 0.0)
	if new_p is AtlasTexture:
		region = Color(
				new_p.region.position.x,
				new_p.region.position.y,
				new_p.region.size.x,
				new_p.region.size.y
		)
	else:
		region = Color(0.0, 0.0, new_p.get_width(), new_p.get_height())
	portrait.material.set_shader_parameter("region", region)


# Updates the number of the initiative label.
func update_initiative_label(init_value: int) -> void:
	initiative.text = String.num_uint64(init_value)


func _ready() -> void:
	update_portrait(portrait.texture)
