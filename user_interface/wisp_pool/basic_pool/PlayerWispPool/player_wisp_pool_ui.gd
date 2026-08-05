class_name PlayerWispPoolUI
extends WispPoolUI
## Represents the wisp pool for the active player.


## Assigns the pool this UI node will display.
func set_wisp_pool(new_pool: WispPool = null) -> void:
	if pool != null:
		pool.active_count_changed.disconnect(_on_WispPool_active_count_changed)
	pool = new_pool
	if pool != null:
		pool.active_count_changed.connect(_on_WispPool_active_count_changed)
		_set_labels()
