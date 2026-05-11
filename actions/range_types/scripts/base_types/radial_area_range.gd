@abstract
class_name RadialAreaRange
extends AreaRange
## Describes an area range whose emission point is in the center of the area.
##
## Child class of AreaRange.


## Base function for radial area ranges that define a general area around a
## starting point.
@abstract func get_area_indexes(start: int, hm: HexMap) -> Array[int]
