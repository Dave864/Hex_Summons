class_name InitiativeSlot
extends PanelContainer
"""
Displays the portrait, current health, and initiative slot of a given character.
"""


export(NodePath) var portrait_ref = null
export(NodePath) var init_label_ref = null
export(NodePath) var health_bar_ref = null

var _portrait: TextureRect = null
var _initiative: Label = null
var _health_bar: ProgressBar = null
# Used for scaling the health bar.
var _max_health: float = 0.0
var _cur_health: float = 0.0


# Updates the details of the slot to represent the new character
func change_character(c: Character) -> void:
	update_cur_health(c.stats.get_stat(Stat.Type.CUR_HEALTH))
	update_max_health(c.stats.get_stat(Stat.Type.MAX_HEALTH))
	_update_health_bar()


# Updates the portrait.
func update_portrait(new_p: Texture) -> void:
	_portrait.texture = new_p


# Updates the text of the initiative label.
func update_initiative_label(text: String) -> void:
	_initiative.text = text


# Updates the health bar to represent the new current health value. Binds the
# value to be within the bounds of health
func update_cur_health(new_cur: int) -> void:
	_cur_health = clamp(float(new_cur), 0.0, _max_health)
	_update_health_bar()


# Updates the health bar to represent the new max health value.
func update_max_health(new_max: int) -> void:
	_max_health = new_max
	_update_health_bar()


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_portrait = get_node(portrait_ref)
	_initiative = get_node(init_label_ref)
	_health_bar = get_node(health_bar_ref)


# Updates the health bar.
func _update_health_bar() -> void:
	_health_bar.max_value = _max_health
	_health_bar.set_value_no_signal(_cur_health)


# Checks that the exported parameters are set.
func _check_for_required_parameters() -> void:
	assert(portrait_ref != null, "Missing reference to portrait.")
	assert(init_label_ref != null, "Missing reference to initiative label.")
	assert(health_bar_ref != null, "Missing reference to health bar.")


# Updates the health display when the character's health changes.
func _on_Character_health_changed(new_value: int, _old_value: int) -> void:
	update_cur_health(new_value)
	_update_health_bar()
