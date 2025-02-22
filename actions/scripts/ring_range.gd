class_name RingRange
extends ActionRange
"""
Describes an action range whose area encompasses all hexes within the defined distance.
"""


# How many tiles out from the cast point the action will affect.
export(int, 0, 1000) var distance = 0
