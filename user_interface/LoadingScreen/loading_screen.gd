class_name LoadingScreen
extends CanvasLayer
## A screen that hides the loading of a new scene.


## Reference to the progress bar that displays the current progress.
@export var progress_bar: ProgressBar = null

## The path to the next scene.
@onready var _next_scene_path = SceneController.load_scene_path
## The current progress of the loading bar.
var _progress: Array[float] = []


## Sets load progress to zero and start loading the next scene.
func _ready() -> void:
	progress_bar.value = 0.0
	ResourceLoader.load_threaded_request.call_deferred(_next_scene_path)


## Loads the next scene.
func _process(_delta: float) -> void:
	var status := ResourceLoader.load_threaded_get_status(
			_next_scene_path,
			_progress
	)
	progress_bar.set_value_no_signal(_progress[0] * 100)
	match status:
		ResourceLoader.THREAD_LOAD_FAILED:
			printerr("Scene at path {0} failed to load.".format([_next_scene_path]))
			_exit_game()
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			printerr("Scene at path {0} is invalid.".format([_next_scene_path]))
			_exit_game()
		ResourceLoader.THREAD_LOAD_LOADED:
			_go_to_next_scene()
		_:
			pass


## Goes to the next scene.
func _go_to_next_scene() -> void:
	var new_scene := ResourceLoader.load_threaded_get(_next_scene_path)
	SceneController.load_scene_path = ""
	get_tree().change_scene_to_packed(new_scene)


## Forces the game to close.
func _exit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
