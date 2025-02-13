extends Node


# Indicates that a map tile has been selected by the cursor
signal tile_selected(info)

# Indicates that a player character's turn has started
signal player_turn_started(player)

# Indicates that a player character's turn has ended
signal player_turn_ended(player)

# Indicates that an enemy character's turn has started
signal enemy_turn_started(path)
