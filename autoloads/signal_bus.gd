extends Node
"""
A collection of signals that need to be referenced by multiple disjointed nodes.
"""


# Signals most relevant in an Encouinter scene.
signal tile_selected(info)
signal selector_required()
signal player_turn_started(player)
signal player_turn_ended(player)
signal enemy_turn_started(path)
