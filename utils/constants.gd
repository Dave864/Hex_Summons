class_name Constants
extends Object
## Collection of constant values and enums that are used in various scripts 
## throughout the game.


## The path to a default icon.
const DEFAULT_ICON_PATH := "res://art/icon.png"
## The path to the map tile texture reference.
const MAP_TEXTURE_REF := "res://art/tile_textures/hex_base_texture.png"
## The path to the mouse cursor icon for panning the encounter camera.
const CURSOR_ICON_CAMERA_P := "res://art/ui/mouse_cursor/cursor_camera_pan.png"
## The path to the mouse cursor icon for panning the rotating the camera.
const CURSOR_ICON_CAMERA_R := "res://art/ui/mouse_cursor/cursor_camera_rot.png"

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

## The collision layer that colliders default to when created.
const DEFAULT_LAYER := 1
## The collision layer for map objects.
const MAP_LAYER := 2
## The collision layer for player characters.
const PLAYER_LAYER := 3
## The collision layer for enemy characters.
const ENEMY_LAYER := 4
