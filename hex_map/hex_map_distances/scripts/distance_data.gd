class_name DistanceData
extends Object
## Records the various distances to a tile on a map.
##
## Records the tile and travel distance to a tile. The tile distance is the
## number of tiles it takes to get to the destination. The travel distance is
## how far one traveled crossing said tiles.


## The number of tiles traveled.
var tile: int = 0
## The total distance traveled.
var travel: float = 0.0


## Initializes a new instance of DistanceData.
func _init(tile_distance: int, travel_distance: float) -> void:
	tile = tile_distance
	travel = travel_distance
