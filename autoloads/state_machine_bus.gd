extends Node


# Keeps track of the current states of various FSMs within an encounter scene.
var encounter_states: Dictionary = {
	"Encounter": null,
	"Selector": null,
	"PlayerCharacter": null,
	"EnemyCharacter": null,
}
