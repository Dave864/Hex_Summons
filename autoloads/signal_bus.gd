extends Node
"""
A collection of signals that need to be referenced by multiple disjointed nodes.
"""


# warning-ignore:unused_signal
signal move_tile_selected(info)
# warning-ignore:unused_signal
signal selector_required(initial_position)
# warning-ignore:unused_signal
signal selector_paused()

# warning-ignore:unused_signal
signal player_turn_started(player)
# warning-ignore:unused_signal
signal player_action_type_canceled()
# warning-ignore:unused_signal
signal player_action_selected(player, action)
# warning-ignore:unused_signal
signal player_action_confirmed(action)
# warning-ignore:unused_signal
signal player_action_canceled(action)
# warning-ignore:unused_signal
signal player_turn_ended(player)

# warning-ignore:unused_signal
signal enemy_turn_started(enemy)
# warning-ignore:unused_signal
signal enemy_actions_required()
# warning-ignore:unused_signal
signal enemy_actions_confirmed(action_chain)
# warning-ignore:unused_signal
signal enemy_turn_ended(enemy)
