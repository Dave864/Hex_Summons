@abstract
class_name DirectionalAreaRange
extends AreaRange
## Describes an area range that has a directional compmenent to it, i.e the area
## goes out in a direction from the emission point.
## 
## Child class of AreaRange.


## Base function for directional area ranges that define an area emitted in a
## direction from starting point.
@abstract func get_dir_area_indexes(
	start: int,
	dir: int,
	hm: HexMap
) -> Array[int]
