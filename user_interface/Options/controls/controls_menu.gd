class_name ControlsMenu
extends Control
## Menu that handles the setting of input bindings.
##
## Handles the swapping between different input sources as well as saving current
## keybinds and loading default ones. Also handles the loading of keybinds at
## the start of the game.


## Button that sets the displayed input layout as the one to use.
@export var confirm_button: Button = null
## Button that resets all displayed inputs to the default values.
@export var reset_button: Button = null
## Time the popup warning that not all keybinds have been set stays up.
@export_range(0.001, 10.0, 0.001) var not_all_set_popup_time := 1.0
## Delay time before allowing options to recieve other input after confirming
## keybind settings.
@export_range(0.001, 1.0, 0.001) var confirm_keybind_delay_time := 0.01

## The current input source.
var current_source: InputController.Source

## Tab bar for displaying which input source is being used.
@onready var source_tabs: TabBar = $SourceTabs
## Popup for confirming input.
@onready var confirm_popup: PopupConfirmInput = $PopupConfirmInput
## Popup for indicating that not all keybinds have been set.
@onready var not_all_set_popup: PopupPanel = $PopupNotAllSet
## Timer for how long a popup should stay.
@onready var popup_timer: Timer = $PopupTimer
## Container for Interface controls.
@onready var interface_controls: InputGroup = (
		$KeybindOptions/Column1/ItemsInterface
)
## Container for Movement controls.
@onready var movement_controls: InputGroup = (
		$KeybindOptions/Column1/ItemsMovement
)
## Container for Combat controls.
@onready var combat_controls: InputGroup = (
		$KeybindOptions/Column2/ItemsCombat
)
## Container for Combat Camera controls.
@onready var combat_camera_controls: InputGroup = (
		$KeybindOptions/Column2/ItemsCombatCamera
)
## Container for Left Joystick controls.
@onready var left_joystick_controls: InputGroup = (
		$KeybindOptions/Column3/ItemsLeftJoystick
)
## Container for Right Joystick controls.
@onready var right_joystick_controls: InputGroup = (
		$KeybindOptions/Column3/ItemsRightJoystick
)

## Flag that indicates a keybind is being updated.
var _keybind_being_set := false


## Gets the current input source.
func _ready() -> void:
	current_source = InputController.get_source()
	InputController.input_source_changed.connect(
			_on_InputController_source_changed
	)
	popup_timer.timeout.connect(_on_popup_timer_timeout)
	_update_source_tabs_display()
	_update_input_bind_controls()
	_connect_KeyBindInput_signals(interface_controls)
	_connect_KeyBindInput_signals(movement_controls)
	_connect_KeyBindInput_signals(combat_controls)
	_connect_KeyBindInput_signals(combat_camera_controls)
	_connect_KeyBindInput_signals(left_joystick_controls)
	_connect_KeyBindInput_signals(right_joystick_controls)
	hidden.connect(_reset_bindings_to_InputMap)


## Saves the current keybind settings into InputMap.
func save_current_keybinds() -> void:
	var binding_buttons: Array[KeybindInputButton] = []
	binding_buttons.append_array(interface_controls.get_binding_buttons())
	binding_buttons.append_array(movement_controls.get_binding_buttons())
	binding_buttons.append_array(combat_controls.get_binding_buttons())
	binding_buttons.append_array(combat_camera_controls.get_binding_buttons())
	binding_buttons.append_array(left_joystick_controls.get_binding_buttons())
	binding_buttons.append_array(right_joystick_controls.get_binding_buttons())
	var input_binds: Dictionary[String, Array] = {}
	for bind_button: KeybindInputButton in binding_buttons:
		var inputEvents: Array[InputEvent] = []
		var keymouse_bind := bind_button.keymouse_keybind()
		if keymouse_bind != null:
			inputEvents.append(keymouse_bind)
			if keymouse_bind is InputEventKey:
				var keypad_match := OptionsController.get_input_for_keypad(
						keymouse_bind
				)
				if keypad_match != null:
					inputEvents.append(keypad_match)
			bind_button.set_keymouse_keybinds_to_InputMap()
		var gamepad_keybind := bind_button.gamepad_keybind()
		if gamepad_keybind != null:
			bind_button.set_gamepad_keybinds_to_InputMap()
			inputEvents.append(gamepad_keybind)
		input_binds[bind_button.input_bind] = inputEvents
	OptionsController.save_custom_keybinds_to_file(input_binds)


## Returns if a keybind is being set.
func is_keybind_being_set() -> bool:
	return _keybind_being_set


## Goes through the KeyBindInput controls and connects their signals to this
## node.
func _connect_KeyBindInput_signals(controls_group: InputGroup) -> void:
	for item: Node in controls_group.get_child(0).get_children():
		var input_button: KeybindInputButton = item.get_child(1)
		input_button.new_bind_requested.connect(
				_on_KeyBindInputButton_new_bind_requested
		)
		input_button.new_bind_set.connect(_on_KeyBindInputButton_new_bind_set)
		input_button.new_bind_requested.connect(
				confirm_popup._on_KeybindInputButton_new_bind_requested
		)
		input_button.new_bind_set.connect(
				confirm_popup._on_KeybindInputButton_new_bind_set
		)


## Updates the source tabs to reflect the current input source.
func _update_source_tabs_display() -> void:
	if current_source == InputController.Source.KEYBOARD_AND_MOUSE:
		source_tabs.set_tab_disabled(0, false)
		source_tabs.current_tab = 0
		source_tabs.set_tab_disabled(1, true)
	else:
		source_tabs.set_tab_disabled(1, false)
		source_tabs.current_tab = 1
		source_tabs.set_tab_disabled(0, true)


## Updates the input binding controls to reflect the current input source.
func _update_input_bind_controls() -> void:
	var com_cam_rotate: HBoxContainer = (
			combat_camera_controls.get_node("VBoxContainer/Rotate")
	)
	var com_cam_reset: KeybindInputButton = (
			combat_camera_controls.get_node(
				"VBoxContainer/Reset/KeybindInputButton"
			)
	)
	if current_source == InputController.Source.KEYBOARD_AND_MOUSE:
		com_cam_rotate.show()
		com_cam_reset.set_input_to_keymouse()
		var node_path := (
				movement_controls.get_node(
					"VBoxContainer/Left/KeybindInputButton"
				).get_path()
		)
		com_cam_reset.focus_neighbor_left = node_path
		com_cam_reset.focus_neighbor_right = node_path
		$KeybindOptions/Column1/HSeparator.show()
		$KeybindOptions/Column1/LabelMovement.show()
		$KeybindOptions/Column1/ItemsMovement.show()
		$KeybindOptions/Column3.hide()
	else:
		com_cam_rotate.hide()
		com_cam_reset.set_input_to_gamepad()
		com_cam_reset.focus_neighbor_left = (
				interface_controls.get_node(
					"VBoxContainer/Accept/KeybindInputButton"
				).get_path()
		)
		com_cam_reset.focus_neighbor_right = (
				right_joystick_controls.get_node(
					"VBoxContainer/Left/KeybindInputButton"
				).get_path()
		)
		$KeybindOptions/Column1/HSeparator.hide()
		$KeybindOptions/Column1/LabelMovement.hide()
		$KeybindOptions/Column1/ItemsMovement.hide()
		$KeybindOptions/Column3.show()
	_update_input_bind_group(interface_controls)
	_update_input_bind_group(combat_controls)


## Updates the specific group of input binding controls to match the current
## input source.
func _update_input_bind_group(controls_group: InputGroup) -> void:
	for item: Node in controls_group.get_child(0).get_children():
		var input_button: KeybindInputButton = item.get_child(1)
		if current_source == InputController.Source.KEYBOARD_AND_MOUSE:
			input_button.set_input_to_keymouse()
		else:
			input_button.set_input_to_gamepad()


## Disables the confirm and reset buttons to prevent them from being selectable
## during input bind update.
func _on_KeyBindInputButton_new_bind_requested(
	_input_source: InputController.Source
) -> void:
	_keybind_being_set = true
	confirm_button.disabled = true
	reset_button.disabled = true


## Enables the confirm and reset buttons to allow them to be selected after
## updating a key bind.
func _on_KeyBindInputButton_new_bind_set(_id: int) -> void:
	confirm_button.disabled = false
	reset_button.disabled = false
	popup_timer.start(confirm_keybind_delay_time)


## Updates the input map to match the displayed inputs.
func _on_confirm_button_pressed() -> void:
	# Confirm button used for other option tabs, so should only process signal
	# when this tab is active.
	if not visible:
		return
	if (
			interface_controls.all_bindings_unique()
			and movement_controls.all_bindings_unique()
			and combat_controls.all_bindings_unique()
			and combat_camera_controls.all_bindings_unique()
			and left_joystick_controls.all_bindings_unique()
			and right_joystick_controls.all_bindings_unique()
	):
		save_current_keybinds()
		_reset_bindings_to_InputMap()
	else:
		not_all_set_popup.show()
		popup_timer.start(not_all_set_popup_time)


## Updates the input map to be the default, refreshing the display to match.
func _on_reset_button_pressed() -> void:
	# Confirm button used for other option tabs, so should only process signal
	# when this tab is active.
	if not visible:
		return
	OptionsController.load_default_keybinds()
	_reset_bindings_to_InputMap()


## Updates the keybind buttons to reflect the InpuMap settings.
func _reset_bindings_to_InputMap() -> void:
	interface_controls.reset_bindings_to_InputMap()
	movement_controls.reset_bindings_to_InputMap()
	combat_controls.reset_bindings_to_InputMap()
	combat_camera_controls.reset_bindings_to_InputMap()
	left_joystick_controls.reset_bindings_to_InputMap()
	right_joystick_controls.reset_bindings_to_InputMap()


## Hides the currently active popup.
func _on_popup_timer_timeout() -> void:
	if not_all_set_popup.visible:
		not_all_set_popup.hide()
	elif _keybind_being_set:
		_keybind_being_set = false


## Swaps available input binds to match the current input source.
func _on_InputController_source_changed() -> void:
	if not_all_set_popup.visible:
		return
	# Don't swap if confirm popup is present as an input bind is being set.
	# Don't need to redo update logic if input source has not changed.
	if confirm_popup.visible or current_source == InputController.get_source():
		return
	current_source = InputController.get_source()
	_update_source_tabs_display()
	_update_input_bind_controls()
	# Don't want to shift focus if this tab is not active as it would be jarring
	# to players and make it difficult to traverse other option tabs.
	if not visible:
		return
	# Shift focus to accept button as it is present for both input sources.
	# Allows the player to maintain the ability to select obtions using
	# directional inputs.
	(
			interface_controls.get_node(
				"VBoxContainer/Menu/KeybindInputButton"
			).grab_focus()
	)
