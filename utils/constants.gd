class_name Constants
extends Object
## Collection of constant values and enums that are used in various scripts 
## throughout the game.


## The path to a default icon.
const DEFAULT_ICON_PATH: String = "res://art/icon.png"

## This is the number that was found to best conform a fixed size sprite image
## to the pixel size of the viewport dimensions 640 x 360.
const WORLD_PIXEL_SIZE: float = 0.0054

## The maximimum values for various character and attack stats.
const MAX_STAT: int = 1000
const MAX_MAP_DIST: int = 100

## The speed at which characters move from tile to tile.
const MOVE_SPEED: float = 8.0

## The value to use when adjusting the weight of a hex map astar connection point
## to account for characters of the opposite faction of the current active character.
const ASTAR_ADJUSTMENT_WEIGHT = 1000.0

## Common transparency values for materials, defined by opacity.
const OPACITY_FULL: float = 1.0
const OPACITY_THREE_QUARTER: float = 0.75
const OPACITY_HALF: float = 0.5
const OPACITY_QUARTER: float = 0.25
const OPACITY_NONE: float = 0.0
