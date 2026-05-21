extends Node
## Manages the transferring of wisp data between players, the standby pool, and
## any active summon.


## The pool that wisps used by player characters go to.
var standby_pool: SummonWispPool


## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	standby_pool = SummonWispPool.new()
	standby_pool.name = "StandbyWispPool"
	add_child(standby_pool)


## Pays the cost from the player's wisp pool, transferring the spent wisps to
## the standby pool.
func pay_cost_from_player(player_pool: PlayerWispPool, cost: WispCost) -> void:
	for element: Element.Type in cost.cost_summary.keys():
		var spent_wisps: PackedStringArray = player_pool.pay_for_element(
				element,
				cost.cost_summary[element]
		)
		if not WispTracker.set_state_to_standby_set(spent_wisps):
			printerr("Failed to set all spent wisps.")
			return
		standby_pool.add_wisps(spent_wisps, element)



## Pays the cost required to conjure a summon from the controller's standby pool,
## transferring the spent wisps to the summon's wisp pool.
func pay_cost_for_summon(
	summon_pool: SummonWispPool,
	summon_cost: WispCost
) -> void:
	for element: Element.Type in summon_cost.cost_summary.keys():
		var wisps_for_element: PackedStringArray = standby_pool.pay_for_element(
				element,
				summon_cost.cost_summary[element]
		)
		if not WispTracker.set_state_to_summon_set(wisps_for_element):
			printerr("Could not set all spent wisps to be in summon pool.")
			return
		summon_pool.add_wisps(wisps_for_element, element)


## Moves the specified number of wisps in the standby pool back to the specified
## player. Will move as many wisps as possible up to the provided count. The
## moved wisps will always have been bonded to the player. The wisps that are
## moved are otherwise randomly chosen.
func recall_for_player(player_pool: PlayerWispPool, recall_count: int) -> void:
	var bonded_wisps: Dictionary[Element.Core, PackedStringArray] = (
		WispTracker.get_bonded_wisps(player_pool.player_name)
	)
	var standby_pool_wisps: Array[String] = []
	for wisps in bonded_wisps.values():
		for wisp: String in wisps:
			if WispTracker.is_standby_set(wisp):
				standby_pool_wisps.append(wisp)
	standby_pool_wisps.shuffle()
	var random_wisps: Array[String] = standby_pool_wisps.slice(0, recall_count - 1)
	if not WispTracker.set_state_to_player(random_wisps):
		printerr("failed to recall all requested wisps.")
		return
	standby_pool.remove_wisps(random_wisps)
	for wisp: String in random_wisps:
		player_pool.set_active(wisp)


## Pays the cost from the active summon wisp pool, transferring the spent wisps
## to their bonded player's pool.
func pay_cost_from_active_summon(
	summon_pool: SummonWispPool,
	cost: WispCost
) -> void:
	for element: Element.Type in cost.cost_summary.keys():
		var wisps_for_element: Array[String] = summon_pool.pay_for_element(
				element,
				cost.cost_summary[element]
		)
		if not WispTracker.set_state_to_player(wisps_for_element):
			printerr("Could not set all the spent wisps to their host players.")
			return
		for wisp: String in wisps_for_element:
			var host: String = WispTracker.get_bonded_player(wisp)
			var player_pool: PlayerWispPool = (
				PartyController.party_details[host].wisp_pool
			)
			player_pool.set_active(wisp)


## Moves all wisps in standby and summon pools back to the player wisp pools.
func recall_all_to_players(summon_pool: SummonWispPool) -> void:
	var party_details := PartyController.get_active_party_data().values()
	var wisps_in_standby: PackedStringArray = []
	var wisps_in_summon: PackedStringArray = []
	for player: PartyController.PlayerDetails in party_details:
		var bonded_wisps: Dictionary[Element.Core, PackedStringArray] = (
				WispTracker.get_bonded_wisps(player.name)
		)
		for wisp_names: PackedStringArray in bonded_wisps.values():
			for wisp: String in wisp_names:
				if WispTracker.is_standby_set(wisp):
					wisps_in_standby.append(wisp)
				elif WispTracker.is_summon_set(wisp):
					wisps_in_summon.append(wisp)
				else:
					continue
				player.wisp_pool.set_active(wisp)
			WispTracker.set_state_to_player(wisp_names)
	standby_pool.remove_wisps(wisps_in_standby)
	summon_pool.remove_wisps(wisps_in_summon)
