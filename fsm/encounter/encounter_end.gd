class_name EncounterEnd
extends EncounterState
## The logic for what happens when an Encounter scene is in the `End` state.
##
## Goes to the overworld scene.


## Called by the state machine upon changing the active state. The `msg` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	WispController.recall_all_to_players(enc.summon.summon_wisp_pool)
	SceneController.change_scene_to_overworld()
