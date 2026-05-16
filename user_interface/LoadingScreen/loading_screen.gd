class_name LoadingScreen
extends CanvasLayer
## A screen that appears to hide the loading of a new scene.


## Reference to the progress bar that displays the current progress.
@export var progress_bar: ProgressBar = null


## Sets load progress to zero.
func _ready() -> void:
	progress_bar.value = 0.0


## Pings the SceneController to determine the current load progress.
func _process(_delta: float) -> void:
	progress_bar.value = SceneController.get_load_percentage() * 100
