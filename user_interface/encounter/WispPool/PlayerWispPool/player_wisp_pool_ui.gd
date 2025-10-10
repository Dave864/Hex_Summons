class_name PlayerWispPoolUI
extends WispPoolUI
"""
Represents the wisp pool for the active player.
"""


# Assigns the pool this UI node will display.
func set_wisp_pool(new_pool: PlayerWispPool) -> void:
	if pool != null:
		pool.disconnect(
				"active_count_changed",
				self,
				"_on_WispPool_active_count_changed"
		)
	pool = new_pool
	pool.connect("active_count_changed", self, "_on_WispPool_active_count_changed")
	_set_labels()
