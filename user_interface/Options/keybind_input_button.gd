class_name KeybindInputButton
extends Button
## Button that lets a player select the key used for a specific input.
##
## Able to specify the key source for the input (gamepad or mouse & keyboard),
## tracking the selection for each source as a string that is relevant to
## Godot's project input map. Does not override the input, merely specify the
## desired keybind.


## The source to look at for the key binding.
@export var key_source: InputController.Source = InputController.Source.NONE
## The input the key will be bound to.
@export var input_bind: String = ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
