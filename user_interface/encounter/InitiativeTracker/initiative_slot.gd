class_name InitiativeSlot
extends Control
"""
Displays the portrait, current health, and initiative slot of a given character.
"""


onready var initiative: Label = $PortraitFrame/InitPanel/Initiative
onready var portrait: TextureRect = $PortraitFrame/Portrait
onready var p_frame: TextureRect = $PortraitFrame


# Updates the details of the slot to represent the new character
func change_character(c: Character) -> void:
	update_portrait(c.battle_portrait)
	if c is PlayerCharacter:
		p_frame.material.set_shader_param("mod_color", Color.aqua)
	else:
		p_frame.material.set_shader_param("mod_color", Color.red)


# Updates the portrait.
func update_portrait(new_p: Texture) -> void:
	portrait.texture = new_p


# Updates the number of the initiative label.
func update_initiative_label(init_value: int) -> void:
	initiative.text = String(init_value)
