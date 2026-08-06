class_name SpawnParameters
extends Resource
## The values that define the behavior of an enemy character when it is an
## EncounterSpawn in the overworld.


## The speed the spawner moves at while idling.
@export_range(1.0, 15.0, 0.01) var idle_speed := 4.0
## The speed the spawner moves at when reacting.
@export_range(1.0, 15.0, 0.01) var reaction_speed := 8.0
## The distance the spawner can travel while in idle before despawining.
@export_range(0.0, 10.0, 0.01) var idle_despawn_distance := 1.5
## The distance the spawner can travel while in reaction before despawning.
@export_range(0.0, 10.0, 0.01) var reaction_despawn_distance := 2.0
## The time spent in seconds on alert before the character jumps to its reaction.
@export_range(0.0, 10.0, 0.01) var alert_time := 3.0
## How close something must get before it is detected.
@export_range(1.0, 20.0, 0.01) var alert_radius := 8.0
## How close a detected body must be before a reaction is triggered.
@export_range(1.0, 20.0, 0.01) var reaction_radius := 4.0
