extends Node
"""
Manages the transferring of wisp data between players, the summon pool, and
active summon.
"""


var summon_pool: SummonWispPool


# Pays the cost from the player's wisp pool, transferring the spent wisps to
# the summon pool.
func pay_cost_from_player(player_pool: PlayerWispPool, cost: WispCost) -> void:
	for element in cost.summary.keys():
		var spent_wisps: Array = player_pool.pay_for_element(
				element,
				cost.summary[element]
		)
		if not WispTracker.set_state_to_summon_pool(spent_wisps):
			printerr("Failed to set all spent wisps.")
		summon_pool.add_wisps(spent_wisps, element)


# Pays the cost from the summon pool, transferring the spent wisps to the active
# summon pool.
func pay_cost_from_summon_pool(cost: WispCost) -> void:
	pass


# Moves the specified number of wisps in the summon pool back to the specified
# player. Will move as many wisps as possible up to the provided count. The
# moved wisps will always have been bonded to the player. The wisps that are
# moved are otherwise randomly chosen.
func recall_for_player(player_pool: PlayerWispPool, recall_count: int) -> void:
	var bonded_wisps: Dictionary = WispTracker.get_bonded_wisps(player_pool.player_name)
	var summon_pool_wisps: Array = []
	for wisps in bonded_wisps.values():
		for wisp in wisps:
			if WispTracker.is_summon_pool(wisp):
				summon_pool_wisps.append(wisp)
	summon_pool_wisps.shuffle()
	var random_wisps: Array = summon_pool_wisps.slice(0, recall_count - 1)
	if not WispTracker.set_state_to_player(random_wisps):
		printerr("failed to recall all requested wisps.")
	for wisp in random_wisps:
		player_pool.set_active(wisp)


# Pays the cost from the active summon pool, transferring the spent wisps to
# their bonded player's pool.
func pay_cost_from_active_summon(cost: WispCost) -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	summon_pool = SummonWispPool.new()
	summon_pool.name = "SummonWispPool"
	add_child(summon_pool)
