@tool
class_name PanelDialogue
extends Panel
## Panel that displays dialogue text.
##
## Breaks down provided text into distinct sections where the true character count
## falls within the character limit of the panel.


## The size of the panel.
const PANEL_SIZE := Vector2(640.0, 75.0)
## The position of the text.
const TEXT_LABEL_POSITION := Vector2(20.0, 12.0)
## The time in seconds it takes to display the full text.
const FULL_DISPLAY_TIME := 3.0
## The posiiton of the input label.
const INPUT_LABEL_POSITION := Vector2(605.0, -21.0)
## The size of the input label.
const INPUT_LABEL_SIZE := Vector2(30.0, 20.0)
## The maximum number of characters that can be displayed in the text box.
const CHARACTER_LIMIT: int = 160
## The path to the open dialogue sound.
const OPEN_SOUND_PATH := (
		"res://audio/interface/UIAlert_Dialog Screen Appears 03_KRST_NONE.wav"
)
## The path to the progress dialogue sound.
const PROGRESS_SOUND_PATH := (
		"res://audio/interface/UIClick_Accept Button 04_KRST_NONE.wav"
)
## The path to the speak dialogue sound.
const SPEAK_SOUND_PATH := "res://audio/interface/dialogue_001.wav"

## The label that displays the text.
var _text_label: RichTextLabel = null
## The text to display broken up into sections.
var _text_sections: PackedStringArray = []
## The section currently being displayed.
var _displayed_section: int = 0
## The audio stream for opening the dialogue panel.
var _asp_open_dialogue: AudioStreamPlayer = null
## The audio stream for progressing the dialogue text.
var _asp_progress_dialogue: AudioStreamPlayer = null
## The audio stream for speaking the dialogue text.
var _asp_speak_dialogue: AudioStreamPlayer = null


## Initializes the text label if not present.
func _ready() -> void:
	if not has_node("RichTextLabel"):
		_init_RichTextLabel()
	else:
		_text_label = $RichTextLabel
	if not has_node("InputLabel"):
		_init_InputLabel()
	if not has_node("UIOpenDialogue"):
		_init_audio_stream_player(
				_asp_open_dialogue,
				"UIOpenDialogue",
				OPEN_SOUND_PATH
		)
	else:
		_asp_open_dialogue = $UIOpenDialogue
	if not has_node("UIProgressDialogue"):
		_init_audio_stream_player(
				_asp_progress_dialogue,
				"UIProgressDialogue",
				PROGRESS_SOUND_PATH
		)
	else:
		_asp_progress_dialogue = $UIProgressDialogue
	if not has_node("UISpeakDialogue"):
		_init_audio_stream_player(
				_asp_speak_dialogue,
				"UISpeakDialogue",
				SPEAK_SOUND_PATH
		)
	else:
		_asp_speak_dialogue = $UISpeakDialogue
	_asp_speak_dialogue.volume_db = -15.0
	_asp_speak_dialogue.pitch_scale = 0.9
	hide()


## Creates the RichTextLabel for displaying the text.
func _init() -> void:
	name = "PanelDialogue"
	set_anchor.call_deferred(SIDE_LEFT, 0.0)
	set_anchor.call_deferred(SIDE_TOP, 0.792)
	set_anchor.call_deferred(SIDE_RIGHT, 1.0)
	set_anchor.call_deferred(SIDE_BOTTOM, 1.0)
	set_size.call_deferred(PANEL_SIZE)
	set_position.call_deferred(Vector2(0.0, 285.0))
	grow_horizontal = Control.GROW_DIRECTION_BOTH
	grow_vertical = Control.GROW_DIRECTION_BOTH


## Gradually reveals the dialogue text when visible.
func _process(delta: float) -> void:
	if not visible:
		return
	_text_label.visible_ratio += delta / FULL_DISPLAY_TIME
	if _text_label.visible_ratio < 1.0:
		_asp_speak_dialogue.play()


## Progresses the dialogue by either immediately displaying all text of the
## current block or displaying the next block.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		if _text_label.visible_ratio < 1.0:
			_text_label.visible_ratio = 1.0
			_asp_progress_dialogue.play()
		elif _displayed_section < _text_sections.size() - 1:
			_displayed_section += 1
			_text_label.text = _text_sections[_displayed_section]
			_text_label.visible_ratio = 0.0
			_asp_progress_dialogue.play()
		else:
			hide()


## Parses the provided text into section that are each no longer than the
## character limit. If the text is specified to use BBCode, the code tags
## will be ignored when counting the characters. Clears out any previously
## set text.
func set_text(new_text: String, uses_bbcode: bool) -> void:
	_text_sections.clear()
	if not uses_bbcode:
		var section_count := ceili(new_text.length() / float(CHARACTER_LIMIT))
		for section: int in section_count:
			_text_sections.append(
					new_text.substr(section * CHARACTER_LIMIT, CHARACTER_LIMIT)
			)
	else:
		var section_start: int = 0
		var section_count: int = 0
		var letter_count: int = 0
		var bracket_count: int = 0
		for index: int in new_text.length():
			if section_count == CHARACTER_LIMIT:
				_text_sections.append(
						new_text.substr(section_start, letter_count)
				)
				section_count = 0
				section_start = index
				letter_count = 0
			bracket_count += (
					1 if new_text[index] == "["
					else -1 if new_text[index] == "]"
					else 0
			)
			letter_count += 1
			if bracket_count == 0:
				section_count += 1
		var final_section := new_text.substr(section_start, -1)
		if final_section.length() > 0:
			_text_sections.append(final_section)


## Reveals the dialogue panel, setting the text to the first section.
func display() -> void:
	show()
	_asp_open_dialogue.play()
	_displayed_section = 0
	_text_label.text = _text_sections[_displayed_section]
	_text_label.visible_ratio = 0.0


## Instantiates a new RichTextLabel.
func _init_RichTextLabel() -> void:
	_text_label = RichTextLabel.new()
	add_child(_text_label)
	_text_label.name = "RichTextLabel"
	_text_label.bbcode_enabled = true
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_label.visible_characters_behavior = TextServer.VC_GLYPHS_LTR
	if Engine.is_editor_hint():
		_text_label.set_owner(get_tree().edited_scene_root)
	_text_label.set_anchors_preset.call_deferred(Control.PRESET_FULL_RECT)
	_text_label.set_position.call_deferred(TEXT_LABEL_POSITION)
	_text_label.set_size.call_deferred(
			Vector2(
				PANEL_SIZE.x - 2.0 * TEXT_LABEL_POSITION.x,
				PANEL_SIZE.y - 2.0 * TEXT_LABEL_POSITION.y
			)
	)
	_text_label.add_theme_constant_override("line_separation", 5)


## Instantiates a new InputLabel.
func _init_InputLabel() -> void:
	var input_label: InputLabel = (
			load("res://user_interface/InputLabel/InputLabel.tscn").instantiate()
	)
	add_child(input_label)
	if Engine.is_editor_hint():
		input_label.set_owner(get_tree().edited_scene_root)
	input_label.set_anchors_preset.call_deferred(Control.PRESET_TOP_RIGHT)
	input_label.set_position.call_deferred(INPUT_LABEL_POSITION)
	input_label.set_size.call_deferred(INPUT_LABEL_SIZE)
	input_label.z_index = 1


## Instantiates an audio stream player for the provided sound path.
func _init_audio_stream_player(
	asp: AudioStreamPlayer,
	asp_name: String,
	sound_path: String
) -> void:
	asp = AudioStreamPlayer.new()
	add_child(asp)
	asp.name = asp_name
	if Engine.is_editor_hint():
		asp.set_owner(get_tree().edited_scene_root)
	asp.bus = "Interface"
	asp.stream = load(sound_path)
