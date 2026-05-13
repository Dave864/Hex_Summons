@tool
class_name EncounterZone
extends Area3D
## Manages what maps and enemies will be used in an encounter when the
## OverworldAvatar is in this area.
##
## Simulates the ecosystem of the enemies in the zone, which determines which
## ones will be included in an encounter.


## File paths to the possible enemy selections for this zone.
@export_dir var enemies : Array[String]
## Files paths to the possible map selections for this zone.
@export_dir var maps : Array[String]

## Thread that runs the ecosystem simulation for this zone.
var _sim_thread: Thread


## Creates a new CollisionShape if none is present.
func _ready() -> void:
	var body_entered_callable := Callable(self, "_on_EncounterZone_body_entered")
	if not is_connected("body_entered", body_entered_callable):
		connect("body_entered", body_entered_callable)
	var body_exited_callable := Callable(self, "_on_EncounterZone_body_exited")
	if not is_connected("body_exited", body_exited_callable):
		connect("body_exited", body_exited_callable)
	if get_shape_owners().size() == 0:
		var collision_shape := CollisionShape3D.new()
		add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.set_owner(get_tree().edited_scene_root)
		collision_shape.name = "CollisionShape3D"
		collision_shape.debug_color = Color.YELLOW
		collision_shape.debug_fill = false
		collision_shape.shape = BoxShape3D.new()
	_sim_thread = Thread.new()
	_sim_thread.start(Callable(self, "_simulate_ecosystem"))


## Establishes the collision layers of a newly created zone.
func _init() -> void:
	set_collision_layer_value(Constants.DEFAULT_LAYER, false)
	set_collision_layer_value(Constants.MAP_LAYER, true)
	set_collision_mask_value(Constants.DEFAULT_LAYER, false)
	set_collision_mask_value(Constants.PLAYER_LAYER, true)


## Disposes of thread resources.
func _exit_tree() -> void:
	_sim_thread.wait_to_finish()


## Simulates the ecosystem of the enemies to determine the population levels.
func _simulate_ecosystem() -> void:
	pass


## Catches when the player avatar enters the zone.
func _on_EncounterZone_body_entered(_avatar: OverworldAvatar) -> void:
	pass


## Catches when the player avatar exits the zone.
func _on_EncounterZone_body_exited(_avatar: OverworldAvatar) -> void:
	pass
