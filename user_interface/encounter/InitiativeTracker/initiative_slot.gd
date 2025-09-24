class_name InitiativeSlot
extends PanelContainer
"""
Displays the portrait, current health, and initiative slot of a given character.
"""


var _c: Character = null
# Used for scaling the health bar.
var _max_health: float = 0.0
var _cur_health: float = 0.0

onready var initiative: Label = $VBoxContainer/HBoxContainer/Initiative
onready var portrait: TextureRect = $VBoxContainer/HBoxContainer/Portrait
onready var health_bar: ProgressBar = $VBoxContainer/HealthBar


# Updates the details of the slot to represent the new character
func change_character(c: Character) -> void:
	_c = c
	update_portrait(_c.battle_portrait)
	if c is PlayerCharacter:
		health_bar.modulate = Color.aqua
	else:
		health_bar.modulate = Color.red


# Updates the portrait.
func update_portrait(new_p: Texture) -> void:
	portrait.texture = new_p


# Updates the number of the initiative label.
func update_initiative_label(init_value: int) -> void:
	initiative.text = String(init_value)
