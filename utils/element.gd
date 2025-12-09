class_name Element
extends Object
## Collection of enums and constants that describe the element of something.
##
## Elements are broken down into core and alignment. Core elements are Earth,
## Fire, Water, and Wind. Alignment elements are Light and Dark. Elements are
## most often used for magic and resistance and define wisp types.


## All of the elements in the game
enum Type {
	EARTH,
	FIRE,
	WATER,
	WIND,
	LIGHT,
	DARK,
}

## The core elements.
enum Core {
	EARTH,
	FIRE,
	WATER,
	WIND,
}

## The alignment elements. The values are set to match their place in the Type
## enum.
enum Alignment {
	LIGHT = 4,
	DARK = 5,
}
