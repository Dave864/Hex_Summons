class_name CharacterLabel
extends Control
"""
UI element that follows a character position that displays the character health
and next iniative.
"""


enum CharType {
	ENEMY,
	PLAYER,
	NONE
}

export(float, -20.0, 20.0) var y_offset = 0.0
export(CharType) var character_type = CharType.NONE
export(NodePath) var character_pos_ref = null

var _char_pos: Position3D = null

onready var _data_container: HBoxContainer = $HBoxContainer
onready var _initiative_label: Label = $HBoxContainer/InitiativeLabel
onready var _health_bar: ProgressBar = $HBoxContainer/PanelContainer/HealthBar
onready var _camera: Camera = get_viewport().get_camera()
onready var _half_label_length: float = _data_container.rect_size.x / 2.0


# Sets the value of the current health.
func set_cur_health(value: int) -> void:
	print("old value: %d" % [_health_bar.value])
	var true_value: float = clamp(value, 0.0, _health_bar.max_value)
	_health_bar.set_value_no_signal(true_value)
	print("new value: %d" % [_health_bar.value])


# Sets the value of max health.
func set_max_health(value: int) -> void:
	_health_bar.max_value = float(value)


# Updates the initiative label.
func set_initiative_label(new_iniative: int) -> void:
	_initiative_label.text = String(new_iniative)


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_char_pos = get_node(character_pos_ref)
	_set_health_bar_color()


## Moves this element so that it is always above the character position.
#func _process(_delta: float) -> void:
#	var _char_origin: Vector3 = _char_pos.global_transform.origin
#	_data_container.visible = not _camera.is_position_behind(_char_origin)
#	var r_pos: Vector2 = _camera.unproject_position(_char_pos.global_translation)
#	r_pos.x -= _half_label_length
#	r_pos.y -= y_offset
#	_data_container.rect_position = r_pos


# Sets the modulation color of the health bar based on the character type.
func _set_health_bar_color() -> void:
	match character_type:
		CharType.PLAYER:
			_health_bar.modulate = Color.aqua
		CharType.ENEMY:
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
	print("Update health label")
	set_cur_health(new_value)


# Updates the max  health value of the label.
func _on_CharacterStats_max_health_changed(new_value: int) -> void:
	set_max_health(new_value)
