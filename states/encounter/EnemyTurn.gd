extends EncounterState
"""
The logic for what happens when an Encounter scene is in the `EnemyTurn` state.
Handles the encounter logic needed to allow the enemy character to properly
run during their turn. Remains in the `EnemyTurn` state if the next character
in initiative is also an enemy character. Goes to the `PlayerTurn` state if an
player character is next in intiative. Goes to the `End` state if either all
player characters or all enemy characters are defeated. 
"""


"""
TODO: Remove this when you create the AI logic for the EnemyCharacter
"""
var current_character: EnemyCharacter
# The index of tiles that the enemy can move to.
var movement_range: Array = []


# Called by the state machine upon changing the active state. The `msg` parameter
# is a dictionary with arbitrary data the state can use to initialize itself.
func enter(_msg := {}) -> void:
	_set_state_machine_bus(ENEMY_TURN)
	current_character = enc.get_current_character()
	# Send the Enemy state machine the details it needs to figure out what to do.
	SignalBus.emit_signal(
		"enemy_turn_started",
		current_character,
		enc.players,
		enc.hm_astar
	)


# Corresponds to the `_process()` callback.
func update(_delta: float) -> void:
	# Move to the `End` State
	if enc.enemies.size() == 0:
		state_machine.transition_to(END)


# Called by the state machine before changing the active state.
# Use this function to clean up the state.
func exit() -> void:
	enc.progress_initiative()


func _ready_connect_signals() -> void:
	ErrorUtil.connect_signal(
		SignalBus,
		"enemy_turn_ended",
		self,
		"_on_SignalBus_enemy_turn_ended"
	)


func _on_SignalBus_enemy_turn_ended(_enemy: EnemyCharacter) -> void:
	var next_character: Character = enc.get_next_character()
	if next_character is PlayerCharacter:
		state_machine.transition_to(PLAYER_TURN)
	elif next_character is EnemyCharacter:
		state_machine.transition_to(ENEMY_TURN)
