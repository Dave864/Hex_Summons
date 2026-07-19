@abstract
class_name UserCharacterAction
extends UserCharacterState
## The logic for what happens when a Character controlled by the user is in the
## 'Action' state.
##
## The Character executes the provided action and then goes to the 'Wait'
## state.


## Virtual function. Called by the state machine upon changing the active state. 
## The `msg` parameter is a dictionary with arbitrary data the state can use to 
## initialize itself.
func enter(msg := {}) -> void:
	var action: Action = msg["action"]
	var targets: Array[Character] = msg["targets"]
	_orient_to_emission(action)
	_change_target_state(targets, true)
	await action.execute_action()
	_change_target_state(targets, false)
	character.emit_turn_ended()
	_spend_resource_for_action(action)
	state_machine.transition_to(WAIT)


## Orients the character to face the emission point or direction of the action.
func _orient_to_emission(action: Action) -> void:
	var hex_dir: HexUtil.HexDirection
	if action.is_directional():
		hex_dir = action.get_emission_direction()
	else:
		var dir := character.position.direction_to(action.get_emission_pos())
		var dir_xz := Vector2(dir.x, dir.z).normalized()
		hex_dir = HexUtil.get_hex_direction(dir_xz)
	character.character_sprite.face_hex_direction(hex_dir)


## Changes the state of the targets.
func _change_target_state(targets: Array[Character], active: bool) -> void:
	for t: Character in targets:
		if active:
			t.activate_hit_box()
		else:
			t.deactivate_hit_box()


## Triggers any logic that spends resources associated with an action.
@abstract func _spend_resource_for_action(action: Action) -> void
