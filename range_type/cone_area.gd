extends AreaRange
class_name ConeArea
"""
Describes a range whose area can be described as a cone.
"""


# Describes how wide the cone area is.
export (int, 0, 5) var spread = 0
# Describes how far out the cone extends away from the start point.
export (int, 1, 100) var distance = 1
