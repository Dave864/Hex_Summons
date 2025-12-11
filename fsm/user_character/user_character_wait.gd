@abstract
class_name UserCharacterWait
extends UserCharacterState
## The logic for what happens when a user Character is in the `Wait` state.
##
## The Character waits  and is inactive until it is reenabled.


@abstract func enter(_msg: Dictionary = {}) -> void


## Called by the state machine before changing the active state. Use this 
## function to clean up the state.
@abstract func exit() -> void
