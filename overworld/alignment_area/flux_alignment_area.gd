@tool
class_name FluxAlignmentArea
extends AlignmentArea
## Defines an AlignmentArea whose alignments change randomly.


## The distance (time) that must be traveled for the alignment to shift.
@export_range(0.1, 10.0, 0.1) var flux_timer: float = 1.0
## The margin of difference the timer can have.
@export_range(0.0, 5.0, 0.1) var timer_margin: float = 0.0

## The current timer value.
var _timer_value: float = 0.0
## The current duration of the timer.
var _timer_duration: float = 0.0
## The player avatar within this area.
var _avatar: OverworldAvatar = null
## The position the avatar was last observed at.
var _last_position := Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	var body_exited_callable := Callable(self, "_on_AlignmentArea_body_exited")
	if not is_connected("body_exited", body_exited_callable):
		connect("body_exited", body_exited_callable)


## Updates the timer duration by the distance the avatar traveled. Avatar
## movement is handled in physics_process, so to keep the randomized updates
## consistent they are handled here as well.
func _physics_process(_delta: float) -> void:
	if _avatar == null:
		return
	_timer_duration += _last_position.distance_squared_to(_avatar.position)
	if _timer_duration > _timer_value:
		_randomize_alignment()
		_timer_duration = 0.0
	_last_position = _avatar.position


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
		_avatar = player_avatar
		_last_position = _avatar.position
		_timer_duration = 0.0
		_timer_value = randf_range(
				flux_timer - timer_margin,
				flux_timer + timer_margin
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
