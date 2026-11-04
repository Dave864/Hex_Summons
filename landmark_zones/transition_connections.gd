class_name TransitionConnections
extends Resource
## Describes which landmarks connect to what zones and vice-versa.


## Describes the landmark each zone connects to.
@export var zone_to_landmark: Dictionary[String, String] = {}
## Describes the zone each landmark connects to.
@export var landmark_to_zone: Dictionary[String, String] = {}
