extends Node
## Tracks the player's progress towards various objectives.
##
## Currently tracks the number of enemy types that have been defeated.


## The collection of target enemies to kill, the required kill count, and the
## current number killed.
var kill_objectives: Dictionary[String, Array] = {
		"ScuttleShrub": [0, 0],
		"StumbleTree": [0, 0],
		"ElderStumbleTree": [0, 0],
}


## Returns if the kill objectives have been met.
func kill_objectives_met() -> bool:
	var objectives_met := true
	for target_name: String in kill_objectives.keys():
		var kill_target: int = kill_objectives[target_name][0]
		var kill_count: int = kill_objectives[target_name][1]
		objectives_met = false if kill_count < kill_target else objectives_met
	return objectives_met


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
