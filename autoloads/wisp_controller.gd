extends Node
## Manages the transferring of wisp data between players, the standby pool, and
## any active summon.


var standby_pool: SummonWispPool


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	standby_pool = SummonWispPool.new()
	standby_pool.name = "StandbyWispPool"
	add_child(standby_pool)


## Pays the cost from the player's wisp pool, transferring the spent wisps to
## the standby pool.
func pay_cost_from_player(player_pool: PlayerWispPool, cost: WispCost) -> void:
	for element in cost.cost_summary.keys():
		var spent_wisps: Array[String] = player_pool.pay_for_element(
				element,
				cost.cost_summary[element]
		)
		if not WispTracker.set_state_to_standby_set(spent_wisps):
			printerr("Failed to set all spent wisps.")
		standby_pool.add_wisps(spent_wisps, element)


## Pays the cost required to conjure a summon from the controller's standby pool,
## transferring the spent wisps to the summon's wisp pool.
func pay_cost_for_summon(
	summon_pool: SummonWispPool,
	summon_cost: WispCost
) -> void:
	pass


## Moves the specified number of wisps in the standby pool back to the specified
## player. Will move as many wisps as possible up to the provided count. The
## moved wisps will always have been bonded to the player. The wisps that are
## moved are otherwise randomly chosen.
func recall_for_player(player_pool: PlayerWispPool, recall_count: int) -> void:
	var bonded_wisps: Dictionary[Element.Core, Array] = (
		WispTracker.get_bonded_wisps(player_pool.player_name)
	)
	var standby_pool_wisps: Array[String] = []
	for wisps in bonded_wisps.values():
		for wisp in wisps:
			if WispTracker.is_standby_set(wisp):
				standby_pool_wisps.append(wisp)
	standby_pool_wisps.shuffle()
	var random_wisps: Array = standby_pool_wisps.slice(0, recall_count - 1)
	if not WispTracker.set_state_to_player(random_wisps):
		printerr("failed to recall all requested wisps.")
	for wisp in random_wisps:
		player_pool.set_active(wisp)


## Pays the cost from the active summon wisp pool, transferring the spent wisps
## to their bonded player's pool.
func pay_cost_from_active_summon(
	summon_pool: SummonWispPool,
	cost: WispCost
) -> void:
	pass
