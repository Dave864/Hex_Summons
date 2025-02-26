extends Node
"""
A collection of signals that need to be referenced by multiple disjointed nodes.
"""


# Signals most relevant in an Encounter scene.
# warning-ignore:unused_signal
signal tile_selected(info)
# warning-ignore:unused_signal
signal selector_required(initial_position)
# warning-ignore:unused_signal
signal player_turn_started(player)
# warning-ignore:unused_signal
signal player_turn_ended(player)
# warning-ignore:unused_signal
signal enemy_turn_started(enemy, players, hm_astar)
# warning-ignore:unused_signal
signal enemy_turn_ended(enemy)
