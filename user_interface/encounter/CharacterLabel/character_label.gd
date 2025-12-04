class_name CharacterLabel
extends Control
## UI element that follows a character position that displays the character health
## and next iniative.


enum CharType {
	ENEMY,
	PLAYER,
	NONE
}

@export_range(-20.0, 20.0, 0.01) var y_offset: float = 0.0
@export var character_type: CharType = CharType.NONE
@export var character_pos_ref: NodePath = NodePath("")

@onready var _char_pos: Marker3D = get_node(character_pos_ref)
@onready var _data_container: HBoxContainer = $CanvasLayer/HBoxContainer
@onready var _initiative_label: Label = $CanvasLayer/HBoxContainer/InitiativeLabel
@onready var _health_bar: ProgressBar = $CanvasLayer/HBoxContainer/PanelContainer/HealthBar
@onready var _camera: Camera3D = get_viewport().get_camera_3d()
@onready var _half_label_length: float = _data_container.size.x / 2.0


## Sets the value of the current health.
func set_cur_health(value: int) -> void:
	var true_value: float = clamp(value, 0.0, _health_bar.max_value)
	_health_bar.set_value_no_signal(true_value)


## Sets the value of max health.
func set_max_health(value: int) -> void:
	_health_bar.max_value = float(value)


## Updates the initiative label.
func set_initiative_label(new_initiative: int) -> void:
	_initiative_label.text = String.num_int64(new_initiative)


## Called when the node enters the scene tree for the first time.
func _ready():
	_check_for_required_parameters()
	_set_health_bar_color()


## Moves this element so that it is always above the character position.
func _process(_delta: float) -> void:
	var _char_origin: Vector3 = _char_pos.global_transform.origin
	_data_container.visible = not _camera.is_position_behind(_char_origin)
	var r_pos: Vector2 = _camera.unproject_position(_char_pos.global_position)
	r_pos.x -= _half_label_length
	r_pos.y -= y_offset
	# Round position to snap label to pixel position.
	_data_container.position = r_pos.round()


## Sets the modulation color of the health bar based on the character type.
func _set_health_bar_color() -> void:
	match character_type:
		CharType.PLAYER:
			_health_bar.modulate = Color.AQUA
		CharType.ENEMY:
			_health_bar.modulate = Color.RED
		_:
			_health_bar.modulate = Color.WHITE


## Checks that all parameters and variables are properly set.
func _check_for_required_parameters() -> void:
	assert(
			character_pos_ref != null,
			"CharacterLabel missing character position reference."
	)


## Updates the current health value of the label.
func _on_CharacterStats_health_changed(new_value: int, _old_value: int) -> void:
	# Need to set both max and current in order for bar to update visually.
	set_max_health(int(_health_bar.max_value))
	set_cur_health(new_value)


## Updates the max  health value of the label.
func _on_CharacterStats_max_health_changed(new_value: int) -> void:
	# Need to set both max and current in order for bar to update visually.
	set_max_health(new_value)
	set_cur_health(int(_health_bar.value))
