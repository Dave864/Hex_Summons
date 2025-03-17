extends Node
"""
A collection of signals that need to be referenced by multiple disjointed nodes
in the Encounter scene.
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
# Indicates that the action chain for an enemy character needs to be determined.
# Emitted by enemy_character nodes and listened to by the Encounter node.
# warning-ignore:unused_signal
signal enemy_actions_required()
# Indicates that the action chain for an enemy character has been determined.
# Emitted by the Encounter node and listened to by enemy_character nodes.
# warning-ignore:unused_signal
signal enemy_actions_confirmed(action_chain)
# warning-ignore:unused_signal
signal enemy_turn_ended(enemy)

# Indicates that the top vertex relative to camera view has been changed.
# Used for moving the selector around the encounter map using joystick input.
# warning-ignore:unused_signal
signal relative_hex_top_changed(top_vertex)
# Indicates that the camera is curently moving.
# Emitted by the EncounterCamera node. Listened to by the Selector and EncounterUI.
# warning-ignore:unused_signal
signal camera_pan_started()
# Indicates that the camera has stopped moving.
# Emitted by the EncounterCamera node. Listened to by the Selector and EncounterUI.
# warning-ignore:unused_signal
signal camera_pan_stopped()
