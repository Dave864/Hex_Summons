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
	if _c != null:
		_c.stats.disconnect(
				"health_changed",
				self,
				"_on_Character_health_changed"
		)
	ErrorUtil.connect_signal(
			c.stats,
			"health_changed",
			self,
			"_on_Character_health_changed"
	)
	_c = c
	update_portrait(_c.battle_portrait)
	update_max_health(_c.stats.get_stat(Stat.Type.MAX_HEALTH))
	update_cur_health(_c.stats.get_stat(Stat.Type.CUR_HEALTH))
	if c is PlayerCharacter:
		health_bar.modulate = Color.aqua
	else:
		health_bar.modulate = Color.red
	_update_health_bar()


# Updates the portrait.
func update_portrait(new_p: Texture) -> void:
	portrait.texture = new_p


# Updates the number of the initiative label.
func update_initiative_label(init_value: int) -> void:
	initiative.text = String(init_value)


# Updates the health bar to represent the new current health value. Binds the
# value to be within the bounds of health
func update_cur_health(new_cur: int) -> void:
	_cur_health = clamp(float(new_cur), 0.0, _max_health)
	_update_health_bar()


# Updates the health bar to represent the new max health value.
func update_max_health(new_max: int) -> void:
	_max_health = new_max
	_update_health_bar()


# Updates the health bar.
func _update_health_bar() -> void:
	health_bar.max_value = _max_health
	health_bar.set_value_no_signal(_cur_health)


# Updates the health display when the character's health changes.
func _on_Character_health_changed(new_value: int, _old_value: int) -> void:
	update_cur_health(new_value)
	_update_health_bar()
