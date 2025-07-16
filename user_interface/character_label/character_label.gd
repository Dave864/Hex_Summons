class_name CharacterLabel
extends Control
"""
UI element that follows a character position that displays the character health
and next iniative.
"""


export(float, 0.0, 50.0) var y_offset = 0.0
export(Character.Type) var character_type = Character.Type.NONE
export(NodePath) var character_pos_ref = null

var _character_pos: Position3D = null

onready var _initiative_label: Label = $HBoxContainer/InitiativeLabel
onready var _health_bar: ProgressBar = $HBoxContainer/HealthBar
onready var _camera: Camera = get_viewport().get_camera()


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_character_pos = get_node(character_pos_ref)


# Moves this element so that it is always above the character position.
func _physics_process(_delta: float) -> void:
	rect_position = _camera.unproject_position(_character_pos.translation)


# Sets the modulation color of the health bar based on the character type.
func _set_health_bar_color() -> void:
	match character_type:
		Character.Type.PLAYER:
			_health_bar.modulate = Color.aqua
		Character.Type.ENEMY:
			_health_bar.modulate = Color.red
		_:
			_health_bar.modulate = Color.white


func _check_for_required_parameters() -> void:
	assert(
			character_pos_ref != null,
			"CharacterLabel missing character position reference."
	)


# Updates the current health value of the label.
func _on_CharacterStats_health_changed(new_value: int, _old_value: int) -> void:
	_health_bar.set_value_no_signal(new_value)


# Updates the max  health value of the label.
func _on_CharacterStats_max_health_changed(new_value: int) -> void:
	_health_bar.max_value = new_value


# Updates the initiative label.
func _on_InitiativeTracker_initiative_changed(new_iniative: int) -> void:
	_initiative_label.text = String(new_iniative)
