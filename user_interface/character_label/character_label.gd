class_name CharacterLabel
extends Control
"""
UI element that follows a character position that displays the character health
and next iniative.
"""


export(float, 0.0, 50.0) var y_offset = 0.0
export(Character.Type) var character_type = Character.Type.NONE
export(NodePath) var character_pos_ref = null

var _char_pos: Position3D = null

onready var _data_container: HBoxContainer = $CanvasLayer/HBoxContainer
onready var _initiative_label: Label = $CanvasLayer/HBoxContainer/InitiativeLabel
onready var _health_bar: ProgressBar = $CanvasLayer/HBoxContainer/HealthBar
onready var _camera: Camera = get_viewport().get_camera()


# Sets the value of the current health.
func set_cur_health(value: int) -> void:
	_health_bar.set_value_no_signal(value)


# Sets the value of max health.
func set_max_health(value: int) -> void:
	_health_bar.max_value = value


# Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_char_pos = get_node(character_pos_ref)
	_set_health_bar_color()


# Moves this element so that it is always above the character position.
func _physics_process(_delta: float) -> void:
	var _char_origin: Vector3 = _char_pos.global_transform.origin
	_data_container.visible = not _camera.is_position_behind(_char_origin)
	var r_pos: Vector2 = _camera.unproject_position(_char_pos.global_translation)
	_data_container.rect_position = r_pos


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
	set_cur_health(new_value)


# Updates the max  health value of the label.
func _on_CharacterStats_max_health_changed(new_value: int) -> void:
	set_max_health(new_value)


# Updates the initiative label.
func _on_InitiativeTracker_initiative_changed(new_iniative: int) -> void:
	_initiative_label.text = String(new_iniative)
