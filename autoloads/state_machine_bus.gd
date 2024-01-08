extends Node


# Keeps track of the current states of various FSMs within an encounter scene.
var encounter_states: Dictionary = {
	FSM.Encounter.ENCOUNTER: null,
	FSM.Encounter.UI: null,
	FSM.Encounter.SELECTOR: null,
	FSM.Encounter.PLAYER_CHARACTER: null,
	FSM.Encounter.ENEMY_CHARACTER: null,
}
