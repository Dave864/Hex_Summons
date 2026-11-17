extends Node
## Tracks the player's progress towards various objectives.
##
## Currently tracks the number of enemy types that have been defeated.


## The enemies that are tracked.
const TRACKED_ENEMIES: PackedStringArray = [
		"ScuttleShrub",
		"StumbleTree",
		"ElderStumbleTree",
]
## The number of scuttleshrub enemies to kill to complete the objective.
const REQ_COUNT_SCUTTLESHRUB := 8
## The number of stumbletree enemies to kill to complete the objective.
const REQ_COUNT_STUMBLETREE := 5
## The number of elder stumbletree enemies to kill to complete the objective.
const REQ_COUNT_ELDERSTUMBLETREE := 3
## The text summarizing the current objective that is displayed when the pause
## menu is open.
const OBJECTIVE_SUMMARIES: PackedStringArray = [
		"These tranquil mounds offer no secrets. Venture outside to begin sample collection.",
		"Fell stumbletrees to collect samples, then report to the Northwest camp.",
		"Enough samples collected, report to the camp in the Northeast.",
		"Deliver samples to the command tent.",
]

## The current step in the objective track.
var objective_step: int = 0
## The collection of target enemies to kill, the required kill count, and the
## current number killed.
var kill_objectives: Dictionary[String, Array] = {
		TRACKED_ENEMIES[0]: [REQ_COUNT_SCUTTLESHRUB, 0],
		TRACKED_ENEMIES[1]: [REQ_COUNT_STUMBLETREE, 0],
		TRACKED_ENEMIES[2]: [REQ_COUNT_ELDERSTUMBLETREE, 0],
}


## Returns if all the kill objectives have been met.
func all_kill_objectives_met() -> bool:
	var objectives_met := true
	for target_name: String in kill_objectives.keys():
		objectives_met = (
				false if not kill_objective_met(target_name)
				else objectives_met
		)
	return objectives_met


## Returns if the kill objective for the enemy has been met. Returns false if
## the enemy is not currently tracked.
func kill_objective_met(enemy_name: String) -> bool:
	if not kill_objectives.has(enemy_name):
		return false
	else:
		return kill_objectives[enemy_name][0] < kill_objectives[enemy_name][1]


## Marks the character for observation so that the kill objectives will update
## when it is defeated.
func track_enemy(enemy: Character) -> void:
	enemy.defeated.connect(_on_Character_defeated)


## Updates the kill objective tracker to add to the tally.
func _on_Character_defeated(character: Character) -> void:
	character.defeated.disconnect(_on_Character_defeated)
	var enemy_name := character.name.substr(0, character.name.length() - 1)
	if kill_objectives.has(enemy_name):
		kill_objectives[enemy_name][1] += 1
