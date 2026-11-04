@tool
class_name FluxAlignmentArea
extends AlignmentArea
## Defines an AlignmentArea whose alignments change randomly.


## The distance that must be traveled for the alignment to shift.
@export_range(0.1, 10.0, 0.1) var flux_distance: float = 1.0
## The margin of difference for the distances.
@export_range(0.0, 5.0, 0.1) var distance_margin: float = 0.0

## The current distance threshold.
var _flux_value: float = 0.0
## The current distance traveled.
var _distance_traveled: float = 0.0
## The position of the player last frame.
var _prior_position := Vector3.INF
## The player avatar within this area.
var _avatar: OverworldAvatar = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if not body_exited.is_connected(_on_AlignmentArea_body_exited):
		body_exited.connect(_on_AlignmentArea_body_exited)


## Updates the timer duration by the distance the avatar traveled. Avatar
## movement is handled in physics_process, so to keep the randomized updates
## consistent they are handled here as well.
func _physics_process(_delta: float) -> void:
	if _avatar == null:
		return
	_distance_traveled += _avatar.global_position.distance_squared_to(
			_prior_position
	)
	_prior_position = _avatar.global_position
	if _distance_traveled > pow(_flux_value, 2.0):
		_randomize_alignment()
		_distance_traveled = 0.0


## Updates the elemental alignment by randomly modifying the current alignment.
func _randomize_alignment() -> void:
	var option := randi_range(0, 6)
	match option:
		0:
			ElementalAlignment.invert_all_alignments()
		1:
			ElementalAlignment.invert_left_alignments()
		2:
			ElementalAlignment.invert_right_alignments()
		3:
			ElementalAlignment.shift_alignments_cw()
		4:
			ElementalAlignment.shift_alignments_ccw()
		5:
			var random_elements := Element.Core.values()
			random_elements.shuffle()
			ElementalAlignment.swap_elements(random_elements[0], random_elements[1])
		_:
			var random_elements := Element.Core.values()
			random_elements.shuffle()
			ElementalAlignment.set_element_alignments(
					random_elements[0],
					random_elements[1],
					random_elements[2],
					random_elements[3]
			)


## Begins tracking the player avatar.
func _on_AlignmentArea_body_entered(player_avatar: OverworldAvatar) -> void:
	if _avatar == null:
		_prior_position = player_avatar.global_position
		_distance_traveled = 0.0
		_avatar = player_avatar
		_flux_value = randf_range(
				flux_distance - distance_margin,
				flux_distance + distance_margin
		)
		_randomize_alignment()
	else:
		printerr("Another OverworldAvatar is already in the area {}.".format([name]))


## Ends tracking of the player avatar.
func _on_AlignmentArea_body_exited(player_avatar: OverworldAvatar) -> void:
	if _avatar == player_avatar:
		_avatar = null
	else:
		printerr("An untracked Overworld Avatar left the area {}.".format([name]))
