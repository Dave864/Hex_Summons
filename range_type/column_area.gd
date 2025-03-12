tool
extends AreaRange
class_name ColumnArea
"""
Describes a range whose area starts from a point and reaches out in a diamond
shape.
"""


# Describes how wide the diamond area is.
export (int, 0, 100) var spread = 0
# Describes how far out the range extends away from the start point.
export (int, 1, 100) var distance = 1
