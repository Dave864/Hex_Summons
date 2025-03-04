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

A menu that provides full descriptions about the stats and abilities of both players and enemies. It is split into two interfaces, one for player characters and one for enemy characters.

###### Player Details

1. **Player Character Selector**
2. **Enemy Character Selector**

###### Enemy Details

1. **Player Character Selector**
2. **Enemy Character Selector**

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
