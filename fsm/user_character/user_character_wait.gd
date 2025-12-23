@abstract
class_name UserCharacterWait
extends UserCharacterState
## The logic for what happens when a user Character is in the `Wait` state.
##
## The Character waits  and is inactive until it is reenabled.


## Called by the state machine when entering the active state. Indicates that
## the character is waiting.
func enter(_msg: Dictionary[Variant, Variant] = {}) -> void:
	character.emit_is_waiting()
