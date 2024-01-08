extends Node


# Indicates that a map tile has been selected by the cursor
signal tile_selected(info)

# Indicates that the player character's turn has started
signal player_turn_started(player)

# Indicates that the enemy character's turn has started
signal enemy_turn_started(path)
