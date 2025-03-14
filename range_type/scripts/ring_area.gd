class_name RingArea
extends AreaRange
"""
Describes a range whose area encompasses all hexes within a defined distance.
"""


# How many tiles out from the cast point the area will reach.
export(int, 0, 1000) var radius = 0
