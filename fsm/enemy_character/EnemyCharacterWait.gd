extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the 'Wait' state.
The Enemy Character does nothing until it is called upon to act.
"""


# Hit when the enemy character is selected to take its turn.
func _on_Encounter_enemy_turn_started(enemy: EnemyCharacter) -> void:
	if enemy.name == ec.name:
		state_machine.transition_to(THINK)
