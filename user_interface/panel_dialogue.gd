@tool
class_name PanelDialogue
extends Panel
## Panel that displays dialogue text.
##
## Breaks down provided text into distinct sections where the character count
## falls within the character limit of the panel.


## The size of the panel.
const PANEL_SIZE := Vector2(640.0, 75.0)
## The position of the text.
const TEXT_LABEL_POSITION := Vector2(20.0, 12.0)
## The time in seconds it takes to display the full text.
const FULL_DISPLAY_TIME := 3.0
## The posiiton of the input label.
const INPUT_LABEL_POSITION := Vector2(600.0, 48.0)
## The size of the input label.
const INPUT_LABEL_SIZE := Vector2(30.0, 20.0)
## The maximum number of characters that can be displayed in the text box.
const CHARACTER_LIMIT: int = 165
## How many characters must be displayed before the speak sound is played.
const SPEAK_LETTER_FREQUENCY: int = 6
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
var _text_label: Label = null
## The text to display broken up into sections.
var _text_sections: PackedStringArray = []
## Used to determine when to play the speak sound.
var _speak_step: int = 0
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
	if not has_node("Label"):
		_init_Label()
	else:
		_text_label = $Label
	if not has_node("InputLabel"):
		_init_InputLabel()
	if not has_node("UIOpenDialogue"):
		_asp_open_dialogue = _init_audio_stream_player(
				"UIOpenDialogue",
				OPEN_SOUND_PATH
		)
	else:
		_asp_open_dialogue = $UIOpenDialogue
	if not has_node("UIProgressDialogue"):
		_asp_progress_dialogue = _init_audio_stream_player(
				"UIProgressDialogue",
				PROGRESS_SOUND_PATH
		)
	else:
		_asp_progress_dialogue = $UIProgressDialogue
	if not has_node("UISpeakDialogue"):
		_asp_speak_dialogue = _init_audio_stream_player(
				"UISpeakDialogue",
				SPEAK_SOUND_PATH
		)
	else:
		_asp_speak_dialogue = $UISpeakDialogue
	_asp_speak_dialogue.volume_db = -15.0
	_asp_speak_dialogue.pitch_scale = 0.9
	hide()


## Initializes the anchor points.
func _init() -> void:
	# Panel details should not be reset when game is running.
	if not Engine.is_editor_hint():
		return
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
	if not visible or Engine.is_editor_hint():
		return
	if _text_label.visible_ratio < 1.0:
		var display_count := ceili(
				CHARACTER_LIMIT / FULL_DISPLAY_TIME * delta
		)
		_text_label.visible_characters += display_count
		_speak_step += display_count
		if _speak_step >= SPEAK_LETTER_FREQUENCY:
			_asp_speak_dialogue.play()
			_speak_step = 0


## Progresses the dialogue by either immediately displaying all text of the
## current block or displaying the next block.
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		accept_event()
		if _text_label.visible_ratio < 1.0:
			_text_label.visible_characters = -1
			_asp_speak_dialogue.play()
			_asp_progress_dialogue.play()
		elif _displayed_section < _text_sections.size() - 1:
			_displayed_section += 1
			_text_label.text = _text_sections[_displayed_section]
			_text_label.visible_characters = 0
			_asp_progress_dialogue.play()
		else:
			hide()


## Parses the provided text into section that are each no longer than the
## character limit. Clears out any previously set text.
func set_text(new_text: String) -> void:
	_text_sections.clear()
	var paragraph_tokens := new_text.split("\n[b]\n")
	for paragraph: String in paragraph_tokens:
		var word_tokens := paragraph.split(" ", false)
		_get_text_sections(word_tokens)


## Reveals the dialogue panel, setting the text to the first section.
func display() -> void:
	show()
	_asp_open_dialogue.play()
	_speak_step = 0
	_displayed_section = 0
	_text_label.text = _text_sections[_displayed_section]
	_text_label.visible_characters = 0


## Instantiates a new Label.
func _init_Label() -> void:
	_text_label = Label.new()
	add_child(_text_label)
	_text_label.name = "Label"
	# Set minimum size to address node condiguration warning.
	_text_label.custom_minimum_size = Vector2(1.0, 1.0)
	_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
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
	input_label.set_anchors_preset.call_deferred(Control.PRESET_BOTTOM_RIGHT)
	input_label.set_position.call_deferred(INPUT_LABEL_POSITION)
	input_label.set_size.call_deferred(INPUT_LABEL_SIZE)
	input_label.z_index = 1


## Instantiates an audio stream player for the provided sound path.
func _init_audio_stream_player(
	asp_name: String,
	sound_path: String
) -> AudioStreamPlayer:
	var asp := AudioStreamPlayer.new()
	add_child(asp)
	asp.name = asp_name
	if Engine.is_editor_hint():
		asp.set_owner(get_tree().edited_scene_root)
	asp.bus = "Interface"
	asp.stream = load(sound_path)
	return asp


## Organizes the words into sections.
func _get_text_sections(words: PackedStringArray) -> void:
		var section_text: String = ""
		var letter_count: int = 0
		for word: String in words:
			if letter_count + word.length() >= CHARACTER_LIMIT:
				letter_count = 0
				section_text.trim_suffix(" ")
				_text_sections.append(section_text)
				section_text = ""
			letter_count += word.length() + 1
			section_text += word + " "
		section_text.trim_suffix(" ")
		_text_sections.append(section_text)
