extends Node
"""
Manages the transferring of wisp data between players, the summon pool, and
active summon.
"""


# Pays the cost from the player's wisp pool, transferring the spent wisps to
# the summon pool.
func pay_cost_from_player(player_pool: PlayerWispPool, cost: WispCost) -> void:
	pass


# Pays the cost from the summon pool, transferring the spent wisps to the active
# summon pool.
func pay_cost_from_summon_pool(cost: WispCost) -> void:
	pass


# Returns the specified number of wisps in the summon pool back to the specified
# player. Will return as many wisps as possible up to the provided count. The
# wisps returned are ones that are bonded to the player, but which ones that
# are returned is random.
func recall_for_player(player_pool: PlayerWispPool, recall_count: int) -> void:
	pass


# Pays the cost from the active summon pool, transferring the spent wisps to
# their bonded player's pool.
func pay_cost_from_active_summon(cost: WispCost) -> void:
	pass
