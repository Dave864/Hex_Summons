class_name ControlsMenu
extends Control
## Menu that handles the setting of input bindings.
##
## Handles the swapping between different input sources as well as saving current
## keybinds and loading default ones.


## Button that sets the displayed input layout as the one to use.
@export var confirm_button: Button = null
## Button that resets all displayed inputs to the default values.
@export var reset_button: Button = null

## The current input source.
var current_source: InputController.Source

## Tab bar for displaying which input source is being used.
@onready var source_tabs: TabBar = $SourceTabs
## Popup for confirming input.
@onready var confirm_popup: PopupConfirmInput = $PopupConfirmInput
## Container for Interface controls.
@onready var interface_controls: VBoxContainer = (
		$KeybindOptions/Column1/ItemsInterface/VBoxContainer
)
## Container for Movement controls.
@onready var movement_controls: VBoxContainer = (
		$KeybindOptions/Column1/ItemsMovement/VBoxContainer
)
## Container for Combat controls.
@onready var combat_controls: VBoxContainer = (
		$KeybindOptions/Column2/ItemsCombat/VBoxContainer
)
## Container for Combat Camera controls.
@onready var combat_camera_controls: VBoxContainer = (
		$KeybindOptions/Column2/ItemsCombatCamera/VBoxContainer
)
## Container for Left Joystick controls.
@onready var left_joystick_controls: VBoxContainer = (
		$KeybindOptions/Column3/ItemsLeftJoystick/VBoxContainer
)
## Container for Right Joystick controls.
@onready var right_joystick_controls: VBoxContainer = (
		$KeybindOptions/Column3/ItemsRightJoystick/VBoxContainer
)


## Gets the current input source.
func _ready() -> void:
	current_source = InputController.get_source()
	_update_source_tabs_display()
	_update_input_bind_controls()
	_connect_KeyBindInput_signals(interface_controls)
	_connect_KeyBindInput_signals(movement_controls)
	_connect_KeyBindInput_signals(combat_controls)
	_connect_KeyBindInput_signals(combat_camera_controls)
	_connect_KeyBindInput_signals(left_joystick_controls)
	_connect_KeyBindInput_signals(right_joystick_controls)


## Swaps available input binds to match the current input source.
func _process(_delta: float) -> void:
	# Don't swap if popup is present as an input bind is being set. Don't need
	# to redo update logic if input source has not changed.
	if confirm_popup.visible or current_source == InputController.get_source():
		return
	current_source = InputController.get_source()
	_update_source_tabs_display()
	_update_input_bind_controls()


## Goes through the KeyBindInput controls and connects their signals to this
## node.
func _connect_KeyBindInput_signals(controls_group: VBoxContainer) -> void:
	for item: Node in controls_group.get_children():
		var input_button: KeybindInputButton = item.get_child(1)
		input_button.new_bind_requested.connect(
				_on_KeyBindInputButton_new_bind_requested
		)
		input_button.new_bind_set.connect(_on_KeyBindInputButton_new_bind_set)


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
	var com_cam_rotate: HBoxContainer = combat_camera_controls.get_node(
			"Rotate"
	)
	var com_cam_reset: KeybindInputButton = combat_camera_controls.get_node(
			"Reset/KeybindInputButton"
	)
	if current_source == InputController.Source.KEYBOARD_AND_MOUSE:
		com_cam_rotate.show()
		com_cam_reset.set_input_to_keymouse()
		var node_path := (
				movement_controls.get_node("Left/KeybindInputButton").get_path()
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
		com_cam_reset.focus_neighbor_left = interface_controls.get_node(
				"Accept/KeybindInputButton"
		).get_path()
		com_cam_reset.focus_neighbor_right = right_joystick_controls.get_node(
				"Left/KeybindInputButton"
		).get_path()
		$KeybindOptions/Column1/HSeparator.hide()
		$KeybindOptions/Column1/LabelMovement.hide()
		$KeybindOptions/Column1/ItemsMovement.hide()
		$KeybindOptions/Column3.show()
	_update_input_bind_group(interface_controls)
	_update_input_bind_group(combat_controls)


## Updates the specific group of input binding controls to match the current
## input source.
func _update_input_bind_group(controls_group: VBoxContainer) -> void:
	for item: Node in controls_group.get_children():
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
	confirm_button.disabled = true
	reset_button.disabled = true


## Enables the confirm and reset buttons to allow them to be selected after
## updating a key bind.
func _on_KeyBindInputButton_new_bind_set() -> void:
	confirm_button.disabled = false
	reset_button.disabled = false


## Updates the input map to match the displayed inputs.
func _on_confirm_button_pressed() -> void:
	pass


## Updates the input map to be the default, refreshing the display to match.
func _on_reset_button_pressed() -> void:
	pass
