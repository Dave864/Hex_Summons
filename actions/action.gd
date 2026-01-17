class_name Action
extends Node
## Describes the details of an action.


## The stats associated with this action.
@export var stats: ActionStats = null

## The path to the stats of the character that owns this action.
var source_stats: StatModifiers = null:
	set(new_source):
		source_stats = new_source
		# Updates the stats references of the effects to be the same as the
		# action.
		_effects_list.set_source_stats(source_stats)

## Whether the effect is emitted from caster in a direction or emitted from a
## chosen location.
var _is_directional: bool = false
## The index of the tile the effect is emitted from.
var _emission_map_index: int = -1
## The transform the effect is emitted from.
var _emission_transform: Transform3D = Transform3D.IDENTITY
## The direction the effect is emitted. Only updated if the action is directional.
var _emission_direction: int

## The animation player for this node.
@onready var ani_player: AnimationPlayer = $AnimationPlayer
## The list of effects for this action.
@onready var _effects_list: EffectsList = $EffectsList
## The hit box object.
@onready var _hit_box: ActionHitBox = $ActionHitBox
## The point the camera should focus on when the action is executing.
@onready var _camera_focus_point: Marker3D = $ActionHitBox/CameraFocusPoint


func _ready() -> void:
	_check_for_required_parameters()
	_effects_list.set_action_potency(stats.potency)
	_is_directional = stats.emit_from_caster
	set_emission_direction(HexUtil.HexDirection.UPPER_LEFT)


## Returns the effects of this action.
func get_effects() -> Array[ActionEffect]:
	return _effects_list.get_effects()


## Returns if the effect range is bound directionally or not.
func get_is_directional() -> bool:
	return _is_directional


## Returns a set of targets this action effects.
func get_targets() -> Dictionary[ActionEffect.Target, bool]:
	var targets: Dictionary[ActionEffect.Target, bool] = {}
	for effect: ActionEffect in _effects_list.get_effects():
		targets[effect.target] = true
	return targets


## Set the tile index the effect is emitted from.
func set_emission_map_index(index: int) -> void:
	_emission_map_index = index


## Return the index of the map tile the emission point is at.
func get_emission_map_index() -> int:
	return _emission_map_index


## Returns the origin point of the emission transform.
func get_emission_pos() -> Vector3:
	return _emission_transform.origin


## Updates the origin of the emission transform.
func set_emission_pos(pos: Vector3) -> void:
	_emission_transform.origin = pos
	_hit_box.transform = _emission_transform


## Set the direction of the emission (0 - 5). Only updates the direction if
## the action is emitted from center.
func set_emission_direction(dir: int) -> void:
	if stats.emit_from_caster:
		_emission_direction = 0 if dir < 0 else 5 if dir > 5 else dir
		_emission_transform.basis = Basis(
				Vector3.UP,
				HexUtil.dir_rotation(_emission_direction)
		)
	else:
		_emission_direction = -1
		_emission_transform.basis = Basis.IDENTITY
	_hit_box.transform = _emission_transform


## Get the direction of the emission. Returns -1 if the action is not directional.
func get_emission_direction() -> int:
	return _emission_direction


## Get the hit box area of this action.
func get_hit_box() -> ActionHitBox:
	return _hit_box


## Resets the position of the emittor.
func reset_emittor_position() -> void:
	_emission_map_index = -1


## Executes the action. Returns true when finished
func execute_action() -> bool:
	_hit_box.transform = _emission_transform
	_hit_box.activate()
	ani_player.play("execute")
	await ani_player.animation_finished
	_hit_box.deactivate()
	ani_player.play("RESET")
	return true


## Sets the caster id reference in the action hit box.
func initialize_caster_id(caster_id: int) -> void:
	_hit_box.caster_id = caster_id


## Signals that the encounter camera should snap to the focus position. Used
## as part of the "execute" animation.
func _signal_focus_camera_snap() -> void:
	SignalBus.emit_position_camera_focus(
			_camera_focus_point.global_position,
			TrackingPoint.MovementType.SNAP
	)


## Signals that the encounter camera should slide to the focus position. Used
## as part of the "execute" animation.
func _signal_focus_camera_linear() -> void:
	SignalBus.emit_position_camera_focus(
			_camera_focus_point.global_position,
			TrackingPoint.MovementType.LINEAR
	)


## Signals that the encounter camera should gently slide to the focus position.
## Used as part of the "execute" animation.
func _signal_focus_camera_decay() -> void:
	SignalBus.emit_position_camera_focus(
			_camera_focus_point.global_position,
			TrackingPoint.MovementType.DECAYING
	)


## Checks that all required parameters are set.
func _check_for_required_parameters() -> void:
	assert(
			stats != null,
			"Action {0} missing stats.".format([name])
	)
