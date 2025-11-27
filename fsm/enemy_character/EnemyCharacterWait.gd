extends EnemyCharacterState
## The logic for what happens when an Enemy Character is in the 'Wait' state.
##
## The Enemy Character does nothing until it is called upon to act.


func enter(_msg := {}) -> void:
	ec.emit_is_waiting()


## To be called in the _ready function to connect signals to 
## the state. The signals connected here should not be required by other states.
func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
			SignalBus,
			"enemy_turn_started",
			self,
			"_on_SignalBus_enemy_turn_started"
	)


## Hit when the enemy character is selected to take its turn.
func _on_SignalBus_enemy_turn_started(enemy: EnemyCharacter) -> void:
	if enemy.get_instance_id() == ec.get_instance_id():
		state_machine.transition_to(THINK)
