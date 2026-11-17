class_name EndObjectivePlace
extends Node3D
## A location in a landmark zone that the player can interact with to end the
## game.
##
## Checks if the player has completed all the objectives to end the game. Places
## the player avatar at some point if the end game objective has not been met.


## Indicates that the game objectives have been verified to be complete.
signal objectives_met
## Indicates that the game objectives have been verified to be incomplete.
signal objectives_pending

## The point the player is placed if objective is not met.
@export var reset_point: Marker3D = null


## Updates the objective step to final step.
func _ready() -> void:
	ObjectiveTracker.set_objective_step(4)


## Checks if the full game objectives have been met. Places the player at the
## reset point if they have not.
func _on_entrance_body_entered(player: Node3D) -> void:
	if ObjectiveTracker.all_kill_objectives_met():
		objectives_met.emit()
	else:
		objectives_pending.emit()
		player.global_position = reset_point.global_position
