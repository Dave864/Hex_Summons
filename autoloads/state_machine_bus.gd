extends Node
"""
A collection of dictionaries that keep track of the current state of the FSMs
within different scenes.
"""

# Keeps track of the current states of various FSMs within an encounter scene.
var encounter_states: Dictionary = {
	FSM.Encounter.ENCOUNTER: null,
	FSM.Encounter.UI: null,
	FSM.Encounter.SELECTOR: null,
	FSM.Encounter.PLAYER_CHARACTER: null,
	FSM.Encounter.ENEMY_CHARACTER: null,
}
