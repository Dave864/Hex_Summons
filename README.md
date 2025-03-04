# Hex Summons (Name Pending)

## Overview

This project is an RPG where combat encounters are rendered as tactics battles that take place on a hexagonal grid. The user assumes control of a party of up to four player characters, whose stats and abilities are determined by how many different elemental "spirits" are attached to them.

## Story

(To Be Written)
The game follows the story of two friends as they embark on a journey across the world. Along the way, they will team up with two others. The journey will have the party encounter various researchers studying the ruins and remnants of lost civilizations, as well as the growing threat of monsters.

The game starts with the two starting characters fending off an animal attack against a visitor to their town. This will prompt them to delve deeper into the wilds surrounding the town to investigate why the animals are so aggressive. This will culminate in a boss battle against a monster that is the result of the unrest.

### Characters

#### Player Characters

- StartingCharacter1
  - **Overview:** An amateur ecologist who was apprenticing for the starting town's apothecary who teams up with the other starting protagonist on their adventure. They have a long love of animals and the natural world, and have made friends with an elemental spirit that enables them to use magic.
  - **Personality:** Reserved and quiet. More comfortable around animals and spirits than they are around people.
- StartingCharacter2
  - **Overview:** A town guard of the starting area who teams up with the other starting protagonist on their adventure. They once had dreams of becoming a heroic warrior, inspired by sagas and legends of old. In addition to providing martial aid to their friend, they hope to perhaps fulfill that dream by learning the martial disciplines of the places they visit.
  - **Personality:** Friendly and warm. Believes that strength should be used to defend those who cannot. Stubborn to the point of self-destructive.
- PartyCharacter3
  - **Overview:** A scholar of magic.
  - **Personality:** Haughty.
- PartyCharacter4
  - **Overview:** An archeologist.
  - **Personality:** Curious.

#### Important NPCs

- MonsterEcologist
  - A researcher who has been traveling across the world, cataloging the presence of monsters and how they affect the environments within.
  - They are part of a larger order that is dedicated to tracking and culling monster populations across the world.

## Gameplay

### Controls

The game is intended to be played using a gamepad controller. This game will provide support for mouse and keyboard along with gamepad controllers.

### Combat

Combat takes place on a grid of hexagonal tiles where the user will assume control of the player characters and issue them commands with the goal of defeating an opposing set of enemy characters.

#### Victory and Defeat

- An enemy character is defeated when either their health reaches zero, or they retreat from battle.
- A player character is defeated when their health reaches zero. Defeated player characters are marked as unconscious and cannot be used in the fight.
- A defeated player character can be returned to the fight via abilities that remove the unconscious condition.
- A combat encounter is successful when all enemies are defeated.
  - A successful combat encounter rewards the user (experience, items, etc.).
- A combat encounter is failed when all player characters are defeated. This results in a game over.
  - A user can retreat from a combat encounter, but will recieve no rewards for doing so.

#### User Interface

##### Primary Combat Map

The interface the user will interact with when playing a combat encounter.

![Combat_UI](https://github.com/user-attachments/assets/7d3b50dc-61e3-49c7-8eb1-dfe9d04cf0f8)

1. **Initiative Tracker:** Keeps track of the order the characters will take their turn in. Also indicates the current active character.
2. **Summon Pool:** Indicates the amount of spirits on standby that are available to be used for summoning.
3. **Player Characters Summary:** Displays the current health of all player characters (May want to include some statuses and spirit pool).
4. **Active Player Details:** Displays the current active player character along with their health and spirit pool.
5. **Enemy Summary:** Displays the health and portrait of the enemy that is being highlighted by the Tile Selector. Only appears when an enemy is highlighted.
6. **Player Options:** Only active during a player character's turn. Displays a set of options the user can take for the player. These options are "Technique", "Spell", "Summon", "Item", and "End".
7. **Action Options:** Only active during a player character's turn. Displays a set of options for a selected "Technique", "Spell", "Summon", or "Item" action.
8. **Tile Selector:** Highlights the map tile that will be used for various player character actions (movement, etc.).

##### Character Details

A menu that provides full descriptions about the stats and abilities of both players and enemies. It is split into two interfaces, one for player characters and one for enemy characters. The interface swaps between player and enemy detail menus.

###### Player Details

![Player_Details_UI](https://github.com/user-attachments/assets/06d525b7-ef88-405a-97fb-c04b184f0dc3)

1. **Player Character Selector:** Area for selecting other player characters for detailed view.
2. **Player Sprite Display:** Detailed Player sprite.
3. **Spirit Pool:** The currently allocated spirits and their set status. Can hover over to select specific spirit to see popup of benefits granted.
4. **Spells & Techniques:** Lists of spells and techniques the player currently has access to.
5. **Player Statistics:** Collection of all player stats.
6. **Item Pouch:** List of items allocated to the player.
7. **Enemy Character Selector:** Area for selecting enemy characters for detailed view.

###### Enemy Details

![Enemy_Details_UI](https://github.com/user-attachments/assets/70b35bcc-3fa8-476f-a965-395abf23502b)

1. **Enemy Character Selector:** Area for selecting other enemy characters for detailed view.
2. **Enemy Sprite Display:** Detailed Enemy sprite.
3. **Enemy Bio Display:** Flavor text describing the enemy.
4. **Enemy Statistics:** Collection of all enemy stats.
5. **Enemy Actions:** Collection of actions the enemy is able to execute. Listed in inverse order of priority.
6. **Player Character Selector:** Area for selecting player characters for detailed view.

#### Gameplay Loop

1. All assets are loaded into the Encounter scene.
2. Character initiative is determined.
3. Proceed through initiative order:
   - Character is Player:
     1. Activate Tile Selection.
     2. Activate the Player Options section.
     3. Set Active Player Details.
     4. Wait for user input:
        - Select tile to move to.
        - Select action to take: 
          - **Technique:** Select technique to use as well as the area to use it on.
          - **Spell:** Select spell to use as well as the area to use it on.
          - **Summon:** Select summon to use as well as the area to use it on.
          - **Item:** Select item to use as well as target if applicable.
          - **End:** Immediately end the player turn.
     5. Resolve statuses
     6. Go to next character in initiative.
   - Character is Enemy:
     1. Deactivate Tile Selection.
     2. Deactivate Player Options section.
     3. Clear Active Player Details.
     4. Determine what actions the enemy should take:
        - This is determined by a priority system, where each action the enemy can do is given a priority and or condition.
        - Action feasability are evaluate in priority order, with conditions determining if an action can be done.
        - Enemies are always able to move, barring any outside factors, and will determine where to move as part of the evaluation.
     5. Execute enemy actions.
     6. Resolve statuses.
     7. Go to next character in initiative.
 4. Check for defeated characters:
    - If Enemy Character defeated, remove the character from the combat encounter and the initiative tracker. 
    - If Player Character defeated, remove the character from the initiative tracker and set their status to "unconscious".
 5. Check if one side, Players or Enemies, have all been defeated:
    - If all enemies defeated, combat ends and user obtains rewards.
    - If all players defeated, combat ends and game over is instanced.

#### Elemental Alignment

(To Be Explained.)

##### Spells & Techniques

Range and Effect Areas
- Both spells and techniques are comprised of stats, an area range, and effect range.
- Area range determines which tiles are available as the start point for the effect range.
  - Area ranges can be either cardinal or ring.
![Range_Types](https://github.com/user-attachments/assets/ddfa3dc8-5a05-418e-a34e-8b5ee852913d)
  - Area ranges can have a "dead zone", which is an area from the start point that is considered invalid for selection.
![Area_range](https://github.com/user-attachments/assets/40730557-bd90-4ad8-8a6f-1d0c92ca39e6)
- Effect range determines the tiles that the spell or technique affects.
  - Effect ranges can be ring, column, or cone.
  - Column and cone effect ranges are restricted to cardinal area ranges.
  - Ring effect ranges are restricted to ring area ranges.
  - Points and lines can be created by specific dimensions of effect ranges.
![Effect_Area](https://github.com/user-attachments/assets/e5cfe865-a680-4313-a708-2f2234f1f53e)

Spells
- Represents abiliities that are manifested by the channeling of a spirit, in otherwords magic.
- A spell requires a specific number of elemental spirits to be set to the player in order for it to be cast.
- Casting a spell channels a spirit (or spirits, not sure yet), adding them to the summon pool.

Techniques
- Represents physical or martial abilities, such as swinging a sword in an arc or causing a small quake by slamming the ground.
- Usually bound to a cardinal range.
- Some techniques may be granted by specific set spirits (not sure yet).
- Using a technique sets it on a cooldown (not sure if techniques should just always be active).

##### Summoning

This action calls to the field a powerful entity, allowing the user to tap into their abilities. 
- Each summon has an elemental cost that is paid by spirits in the summon pool.
  - Some summons require "light" or "dark" elements. This means that for each such element, one spirit from each of the aligned elements is required.
    - EX: A summon that specifies 1 light element could require 1 water spirit and 1 fire spirit be in the pool depending on elemental alignment.
- When a summon is executed, the player selects an area on the map where the summon will be placed, and an initial effect is executed, be it action or otherwise.
- *Not sure if the summon replaces the turn of the player character who summoned it or if it should be added as a separate character to the intiative track*.
- When on the field, the player determines the actions a summon takes, similarly to how a player character's actions are determined.
  - The actions a summon can take are determined by the spirits used to summon them. These spirits form a well that the summon uses to power its abilities.
  - When a summon uses an action, the required number and element of the spirits are released from the well, sending them back to the player character they were originally set to.
  - When a summon uses an action that would empty its well, the summon disappates and leaves the field.

##### Items

Items are consumables that fully replenish after a combat encounter has ended.
(To Be Expanded Upon.)

### World Traversal

#### User Interface

(To Be Determined)

#### Landmarks

- The world will be comprised of landmarks that represent a town or dungeon area that will be loaded when the world avatar makes contact with it.
- The landmarks will be scattered across a traversible landmass where the user will randomly enter combat encounters.

#### Biomes and Random Encounters

- The landmass will be separated into distinct "biomes", each having their own distinct set of creatures to draw from for the purposes of determining random encounters.
- The creatures associated with each biome will be categorized as either "Predator", "Prey" or "Monster".
- A biome will passively track the percentage distribution of each creature category, simulating an ecosystem.
  - Prey percentage will grow inversly to Predator percentage.
  - Monster percentage increase will lower both Predator and Prey.
  - A successful random encounter with Monster creatures will lower the Monster percentage.
- The enemy characters and tile map used for the encounter will be determined as the user traverses the world map.
  - The encounter will use a random tile map from a predifined set specific to the biome.

### Towns

(To Be Determined)

### Dungeons

(To Be Determined)

## Art Style

(To Be Refined)
A hybrid style, using pxiel art sprites in a 3d environment.

## Sound Effects

(To Be Determined)

## Platforms

- **PC:** Windows and Linux
- **Console:** Currently there are not plans to develop console versions. If I can easily acquire the resources for it, I will consider developing a Switch port.

### Audience

This game is intended for people from their mid to late 20's to the mid 30's. It is designed to emulate and expand upon the Golden Sun series of games, and is intended for people who enjoy turn-based RPGs or tactics-lite games.
