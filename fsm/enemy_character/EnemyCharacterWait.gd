extends EnemyCharacterState
"""
The logic for what happens when an Enemy Character is in the 'Wait' state.
The Enemy Character does nothing until it is called upon to act.
"""


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	pass


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	pass


# Called by the state machine before changing the active state.
func exit() -> void:
	pass


func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
			SignalBusEncounter, 
			"enemy_turn_started", 
			self, 
			"_on_SignalBusEncounter_enemy_turn_started"
	)


# Hit when the enemy character is selected to take its turn.
func _on_SignalBusEncounter_enemy_turn_started(enemy: EnemyCharacter) -> void:
	if enemy.name == ec.name:
		state_machine.transition_to(THINK)
