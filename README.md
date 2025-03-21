# Hex Summons (Name Pending)

# Table of Contents

1. [Introduction](#introduction)
    1. [Summary](#summary)
    2. [Inspirations](#inspirations)
    3. [Player Experience](#player-experience)
    4. [Platform](#platform)
    5. [Software](#software)
    6. [Genre](#genre)
    7. [Target Audience](#target-audience)
2. [Concept](#concept)
    1. [Core Loop](#core-loop)
    2. [Themes](#themes)
    3. [Exploration](#exploration)
        1. [Landmarks](#landmarks)
        2. [Towns](#towns)
        3. [Dungeons](#dungeons)
    8. [Combat](#combat)
        1. [Wisps & Elements](#wisps--elements)
        2. [Items](#items)
        3. [Range and Effect Areas](#range-and-effect-areas)
        4. [Spells & Techniques](#spells--techniques)
        5. [Summoning](#summoning)
        6. [Victory and Defeat](#victory-and-defeat)
    9. [Puzzles](#puzzles)
    10. [Quests](#quests)
    11. [AI / NPCs](#ai--npcs)
    12. [Special Systems](#special-systems)
        1. [Player Character Classes ](#player-character-classes)
        2. [Status Effects](#status-effects)
    13. [Progression](#progression)
3. [Story](#story)
    1. [Setting](#setting)
    2. [Narrative](#narrative)
    3. [Characters](#characters)
        1. [Player Characters](#player-characters)
        2. [Important NPCs](#important-npcs)
    4. [Dialogue](#dialogue)
    5. [Storyboards](#storyboards)
4. [Art](#art)
5. [Audio](#audio)
6. [Game Experience](#game-experience)
    1. [UI / UX](#ui--ux)
    2. [Controls](#controls)
    3. [Menus](#menus)
        1. [Primary Combat Map](#primary-combat-map)
        2. [Character Details](#character-details)
    4. [Diegetics](#diegetics)
    5. [Integration](#integration)
7. [Market Requirements](#market-requirements)
    1. [Priorities](#priorities)
    2. [Minimum Viable Product](#minimum-viable-product)
    3. [Delivery](#delivery)
    4. [Marketing](#marketing)
    5. [Post-Launch](#post-launch)
8. [Technical Requirements](#technical-requirements) 
    1. [Items](#items)
    2. [Weapon Mastery](#weapon-mastery)
    3. [Status Effects](#status-effects)
    4. [Biomes and Random Encounters](#biomes-and-random-encounters) 
    5. [Character Stats](#character-stats)
    6. [Action Potency](#action-potency)

# Introduction

## Summary

*Working Title* is an RPG where combat encounters are tactics battles that take place on a hexagonal grid. The player commands a party of four, wielding martial techniques, spells, and powerful summons to fend off beasts and vanquish monsters. Explore ancient ruins and forgotten dungeons, harnessing the power of elemental wisps to command the forces of earth, fire, water, and wind to manipulate the world to your advantage.

## Inspirations

*Working Title* takes heavy inspiration from the *Golden Sun* franchise of RPGs, replicating the class mechanics and adapting the summon system for tactics battles. The game has its combat encounters rendered as tactics battles, with game feel being similar to the *Fire Emblem* series, *Final Fantasy Tactics Advance*, and *South Park: The Fractured But Whole*. The narrative of the game explores the ideas of exploration, specifically in the context of archeology and general scientific discovery.

![DarkDawnPsynergy](https://github.com/user-attachments/assets/09d58165-122f-40e6-9ae8-59a16fab78c4)

![Mixing_djinni](https://github.com/user-attachments/assets/b618c702-cdbf-4e1d-b309-3976714effbc)

![FinalFantasyTacticsAdvanceGBAScreenshot](https://github.com/user-attachments/assets/e98da52e-f0b9-4fa9-8c87-5870f7a3df48)

![Fire-Emblem-Battle](https://github.com/user-attachments/assets/8db59045-05ca-4c2a-9e00-ae94ec89fc54)

![Fractured_But_Whole_Combat](https://github.com/user-attachments/assets/3a8e8755-2005-4d18-9936-d6bdca75fb23)

## Player Experience

The game is intended to invoke feelings of wonder and curiosity. The world holds many mysteries, ancient ruins of ancient civilzations, strange phenomena rooted in magic, bizzare creatures that make home the most hostile of places, and the emergence of monsters. The player is invited to explore these mysteries, following the party as they help researchers decipher these mysteries. Some will remain mysteries, but the ones that are revealed are intended to instill wonder. And when new rumors come along, the player will be hopefully curious about where this exploration will lead.

## Platform

This game is intended for PC release, with focus on Windows OS. Console support is dependent on ease of porting, as the game will be designed for controller support.

## Software

*Working Title* will be developed using the Godot engine. 
Art will be generated using Paint.net. Aseprite is under consideration due to its focus on pixel art. No premade art assets have been decided upon, but will be investigated.
Premade sound Godot sound libraries will be looked into.
Music will have to be sourced from libraries that offer affordable music licenses.

## Genre

*Working Title* is an RPG with tactics-style combat set in a fantasy world that has entered its own Renaissance equivalent.

## Target Audience

This game is intended for people from their mid teens to the mid 30's. It is intended for people who are fans of high fantasy, where magic is a fundamental aspect of the world. People who are a fan of tactics games like *Fire Emblem* or *Final Fantasy Tactics Advance* will find the tactics combat of *Working Title* appealing. *Working Title* will interest players seeking a fantasy story where learning of the history and nature of the world is the focus.

# Concept

## Core Loop

The player recieves details about the next narrative beat, usually being directed to a dungeon or town. The player travels to the next area, running into random combat encounters along the way. Combat is rendered as a tactics battle where characters take turns, using texhniques, spells, summons, and items to either drop the opponent's health to zero or cause the opponent to run away.

If the narrative beat is a town, the player can explore the area for hidden items, shops, and rest points. If the narrative beat is a dungeon, the player will need to find their way to the end, leveraging the puzzle mechanics specific to the dungeon along with elemental abilities to overcome obstacles.

There are a set number of narrative beats that must be completed in sequential order. The player is intended to play through all narrative beats. The player wins the game when they encounter all narrative beats, finishing the story.

## Themes

The game is centered around the concepts of exploration and elements. The narrative revolves around characters exploring ruins and out of the way areas in various quests to learn more about the world around them. The elements of earth, fire, water, and wind influence both the magic of the game, and the societies of the game's world. The elements of light and dark have been made manifest as a result of societies throughout history giving them form through combination of the other four.

Character abilities, both player and NPCs, are predominantly defined by the elements of earth, fire, water, and wind. The combination of these elements gives rise to different abilities, such as wind and water manifesting lightning, or earth and fire manifesting valcanic powers. Light and dark are a by-product of combining two of the elements, and can also be used for appropriately themed abilities.

The concept of exploration does not just refer to the physical act of going to a new place and looking around. This concept is meant to encompass scientific and historical analysis, such as paleontology, archeology, and sociology. The narrative will have the player meet different NPCs that specialize in a field that is exploring an aspect of the world. Some will be altruistic, others selfish.

## Exploration

The player can move around and interact with the world in specific ways. The player could push blocks to solve puzzles, slide around on icy floors, or climb up ladders and vines. The player also has access to various elemental magic that allow them to interact with the world in more creative ways. The player could use earth magic to move stone pillars that cannot be reached, or create a new path by using that same magic to cause plant growth that creates a ladder.

The player can talk with NPCs to obtain various benefits. Talking with NPCs can reveal details and hints about where to go for the current narrative beat. Certain NPCs provide services that can only be used by talking with them. Other NPCs provide dialogue that merely provides lore details that further flesh out the world.

### Landmarks

- The world will be comprised of landmarks that represent a town or dungeon area that will be loaded when the world avatar makes contact with it.
- The landmarks will be scattered across a traversible landmass where the user will randomly enter combat encounters.

### Towns

Throughout the world the player will find towns that serve as rest stop and save haven from the combat encounters. Towns are often the starting point of a new narrative beat, making them useful visual shorthand for where the player should go when exploring the overworld. Towns will often have shops where the player can buy new gear or special items that affect consumables. Towns also serve as a gathering point for NPCs that can provide useful hints for out of the way landmarks or strategies for fighting upcoming bosses.

### Dungeons

Dungeons are dangerous areas that contain random encounters and puzzles that the player must overcome to progress to the next narrative beat. Dungeons could be part of the critical path or optional. All dungeons will have a central theme that they are designed around. For some, it is the focus on a new enviromental mechanic. For others, it is a visual motif. Dungeons could be ancient ruins, sprawling forests, or even hideaways.

## Combat

### Wisps & Elements

Elements are the key component that determines the abilities of a character. There are six elements that the game uses: four primary and two polar. The four primary elements are earth, fire, water, and wind. The polar elements are light and dark. Half of the four primary elements match the light polarity, while the other half match the dark polarity. Certain spells and techniques can shift the polarity clockwise or counter-clockwise by either 90 or 180 degrees.

![Element_Alignment_Shift](https://github.com/user-attachments/assets/71150dd2-a0a6-41f5-93e9-66ab0796bdee)
- Polarity element alignment is determined by the combined count of the matching primary elements. A polarity alignment of 1 means that each primary element has an alignment of 1.

Spells and some techniques are dependent on the elemental alignment of a player character. A player character's elemental alignment is determined by the number of wisps set to them of a specific element, as well as their original elemental alignment.
- *Note: A player's base alignment will probably be worth more than one.*

### Items

Items are consumables that fully replenish after a combat encounter has ended. These include health restoration, status curing, or damaging actions.

### Range and Effect Areas

All actions that can be performed by characters in combat are comprised of stats, an area range, and effect range.
- Area range determines which tiles are available as the start point for the effect range.
  - Area ranges can be either cardinal or ring.
![Range_Types](https://github.com/user-attachments/assets/4d5ccf04-0fa5-451a-838e-44bb057450e8)
  - Area ranges can have a "dead zone", which is an area from the start point that is considered invalid for selection.
![Area_range](https://github.com/user-attachments/assets/6dec3b08-7fad-4229-94bd-cfdec4df7137)
- Effect range determines the tiles that the spell or technique affects.
  - Effect ranges can be ring, column, or cone.
  - Column and cone effect ranges are restricted to cardinal area ranges.
  - Ring effect ranges are restricted to ring area ranges.
  - Points and lines can be created by specific dimensions of effect ranges.
  ![Effect_Area](https://github.com/user-attachments/assets/3b204af0-634e-4107-a19d-04748155f16c)

### Spells & Techniques

Spells
- Represents abiliities that are manifested by the channeling of a wisp, in otherwords magic.
- A spell requires a specific number of elemental wisps to be set to the player in order for it to be cast.
- Casting a spell channels a wisp(s), adding it to the summon pool.

Techniques
- Represents physical or martial abilities, such as swinging a sword in an arc or causing a small quake by slamming the ground.
- Usually bound to a cardinal range.
- Techniques are determined by weapon type and class.
- Using a technique sets it on a cooldown.
  - The cooldown could be reset by channeling a wisp, adding it to the summon pool.
  - Using special techniques could require the channeling of a wisp as well.

### Summoning

This action calls to the field a powerful entity, allowing the user to tap into their abilities. 
- Each summon has an elemental cost that is paid by wisps in the summon pool.
  - Some summons require "light" or "dark" elements. This means that for each such element, one wisp from each of the aligned elements is required.
    - EX: A summon that specifies 1 light element could require 1 water wisp and 1 fire wisp be in the pool depending on elemental alignment.
- When a summon is executed, the player selects an area on the map where the summon will be placed, and an initial effect is executed, be it action or otherwise.
- *Not sure if the summon replaces the turn of the player character who summoned it or if it should be added as a separate character to the intiative track*.
- When on the field, the player determines the actions a summon takes, similarly to how a player character's actions are determined.
  - The actions a summon can take are determined by the wisps used to summon them. These wisps form a well that the summon uses to power its abilities.
  - When a summon uses an action, the required number and element of the wisps are released from the well, sending them back to the player character they were originally set to.
  - When a summon uses an action that would empty its well, the summon disappates and leaves the field.

### Victory and Defeat

- An enemy character is defeated when either their health reaches zero, or they retreat from battle.
- A player character is defeated when their health reaches zero. Defeated player characters are marked as unconscious and cannot be used in the fight.
- A defeated player character can be returned to the fight via abilities that remove the unconscious condition.
- A combat encounter is successful when all enemies are defeated.
  - A successful combat encounter rewards the user (experience, items, etc.).
- A combat encounter is failed when all player characters are defeated. This results in a game over.
  - A user can retreat from a combat encounter, but will recieve no rewards for doing so.

## Puzzles

The game will include puzzles in towns and dungeons that involve the manipulation of environmental elements to move forward. These elements can be interacted with directly or by using elemental magic to alter the them in some way.

The player character will be able to directly interact with the environment in specific ways:
- Certain environment objects, like blocks or statues, can be physically pushed by the player.
- Some surfaces have special properties that cause the player to move in different ways.
    - Icy floors could cause the player to slide until they hit an obstacle.
    - Muddy areas could slow player movement down, making them vulnerable to hazards.
- The player is able to jump over small gaps.
- There are climbable elements, such as ladders and vines, that allow the player to ascend or descend to different elevations.

The player character will have access to different elemental magics that allow for the manipulation of the environment in creative ways:
- Earth magic can be used to move stone pillars that are too far out of reach.
- Fire magic could be used to burn away obstructing foliage.
- Ice magic could be used to freeze a watery surface, opening up previously inaccessible areas.
- Wind magic could be used to turn a windmill.

## Quests

The critical path for the game's narrative is essentially a sequence of quests. The player is informed of where they need to go, what actions need to be undertaken, and are then rewarded upon completion of those actions. The rewards for critical path quests could include special items or abilities, but those would usually be rewarded during the completion of the quest.

Some quests are optional, given to the players by NPCs in towns or hinted at by environmental clues. These quests can be used to flesh out the world by exposing the character to more niche aspects that may not come up during the critical path. Side quest rewards can include unique weapons, new summons, or upgrade materials for items.

## AI / NPCs

## Special Systems

### Player Character Classes

Player characters only have the level and affinity stat by default. All other stats are defined by a class which is set to them. A player character always has a class. The class is determined by the number and element of the wisps that are set to the character. For example, a player with the earth affinity and no other wisps set to them would be assigned the "Guard" class, which has its own set of stats. When that same character has a water wisp set to them, their class then changes to the "Herbalist" class. While this introduces the potential for an unmanageable number of classes, in reality individual classes can be condensed into class chains that each player character can bet set to that can be determined by the elemental alignment of the character as determined by the wisps set. Since a player character has an initial affinity, these class chains can be further reduced to a more manageable number.

Class Chain Grouping:
- core
- core + element_1
- core + element_2
- core + element_3
- core + element_1 + element_2
- core + element_1 + element_3
- core + element_2 + element_3
- core + element_1 + element_2 + element_3

Player classes/class chains determine what spells a player has access to. Some classes/class chains may also grant techniques.

### Status Effects

Characters can be afflicted with status effects that can provide boons or banes to the afflicted character. Map tiles in a combat encounter can also be afflicted with a status effect, which will trigger when a character stops on the tile. Status effects on tiles could also effect how easy it is for a character to traverse the tile.

Status effects could also be used to represent a "stance" for a given character, changing the available techniques or actions that a player or enemy character respectively can use. In the same way, status effects can change the behavior of an enemy character.

## Progression

Player characters will gain experience and level up after hitting certain experience thresholds. Still need to decide if the party shares a level, or if each level up independently. Levels will unlock new spells and techniques that characters can use in combat. Throughout the game, players will encounter rogue wisps that can be obtained through a variety of different means. Some wisps require the player to beat them in a fight. Other wisps require a puzzle to be solved. These wisps can be set to characters to unlock different classes which provide different gameplay options in battle.

# Story

## Setting

The world of this game is one of tumultuous magic, where the fundamental forces of fire, earth, water, and wind give rise to phenomena both beatiful and destructive. The peoples and creatures of this world are at the mercy of these capricious forces, on their own powerless to adapt. Yet, where magic flows, the wisps follow. Avatars of these fundamental forces, wisps are elemental wisps that have the ability to channel the flow of magic. By befriending and bonding with these wisps, one too can share in their peculliar ability.

Out of survival instinct, animals were the first to bond with wisps. It was by their whims that stable environments arose. From observation did people too learn to bond with wisps. From this the art of spellcraft arose, and the dawn of civilization with it. As societies rose and fell, and spellcraft practiced and refined, different philosophies on the nature of the arcane forces took shape. All observed that the elements could be aligned with light or darkness. For some, the deep caves and abyss of the sea aligned earth and water as aspects of dark, while the windy heavens and brilliant sun aligned fire and wind to light. Others posited, what is darkness but a shadow cast by an obstruction, and thus fire could be used with all to harness the stygian forces. And others still found new ways to align the forces with light and dark. With this, polarity was given to the fundamental four.

*CONSIDERING FLUFF REWRITE:* Societies rise and fall, yet the stories they tell of their heroes, gods, and mythic beasts endure beyond their cities, becoming myths and legends. The wisps, nigh immortal, have born witness it all. (Essentially, wisps saw or heard tales about the exploits of creatures or people that inspired society's myths. Some of these tales resonate with them and this results in these mythic figures being able to be called forth as summons given enough knowledge of the myth along with the right set of wisps.)

*CONSIDERING FLUFF REWRITE:* (At some point a catastrophe occurs that results in a big chunk of the world getting reduced to a wasteland. This catastrophe was so bad that even the flow of magic was affected, resulting in it bunching up to the point where it coalesces into an unnatural being. This is where monsters come from. From this point on, monsters are a constant threat to both the wilds and to civilization.)

*CONSIDERING FLUFF REWRITE:* (As the ages pass, monsters have ravaged many of the great civilizations of eld. While the world is not on the brink, much has been lost to ravages of time and aberration. People are ever stubborn, and the current day sees many a guild and society dedicated to reclaiming some of what was lost. And there are others still looking dangerously close at a secret that should stay hidden.)

## Narrative

The game follows the story of two friends as they embark on a journey across the world. Along the way, they will team up with two others. The journey will have the party encounter various researchers studying the ruins and remnants of lost civilizations, as well as the growing threat of monsters.

The game starts with the two starting characters fending off an animal attack against a visitor to their town. This will prompt them to delve deeper into the wilds surrounding the town to investigate why the animals are so aggressive. This will culminate in a boss battle against a monster that is the result of the unrest.

The vistor turns out to be a researcher of monsters who has been traveling back to the base of his organization to report his findings and receive his next orders. This researcher will join the party as the other two agree to help escort them to deliver their findings.

Along the way the group come across other settlements that have been subject to monster attacks. The party resolves these issues for a myriad of reasons, some altruistic, others more self serving. These encounters provide additional data for the researcher, which they comment on from time to time.

***To Be Continued***

## Characters

### Player Characters

- StartingCharacter1
  - **Overview:** An amateur ecologist who was apprenticing for the starting town's apothecary who teams up with the other starting protagonist on their adventure. They have a long love of animals and the natural world, and have made friends with a wisp that enables them to use magic.
  - **Personality:** Reserved and quiet. More comfortable around animals and wisps than they are around people.
- StartingCharacter2
  - **Overview:** A town guard of the starting area who teams up with the other starting protagonist on their adventure. They once had dreams of becoming a heroic warrior, inspired by sagas and legends of old. In addition to providing martial aid to their friend, they hope to perhaps fulfill that dream by learning the martial disciplines of the places they visit.
  - **Personality:** Friendly and warm. Believes that strength should be used to defend those who cannot. Stubborn to the point of self-destructive.
- PartyCharacter3
  - **Overview:** A researcher who has been traveling across the world, cataloging the presence of monsters and how they affect the environments within. They are part of a larger order that is dedicated to tracking and culling monster populations across the world.
  - **Personality:** Haughty.
- PartyCharacter4
  - **Overview:** An archeologist.
  - **Personality:** Curious.

### Important NPCs

***Will be Expanded Upon as the Narrative is Developed***

## Dialogue

## Storyboards

***Will be Expanded Upon as the Narrative is Developed***

# Art

(To Be Refined)
A hybrid style, using pxiel art sprites in a 3d environment.

# Audio

# Game Experience

## UI / UX

## Controls

The game is intended to be played using a gamepad controller. This game will provide support for mouse and keyboard along with gamepad controllers.

## Menus

###  Primary Combat Map

The interface the user will interact with when playing a combat encounter.

![Combat_UI](https://github.com/user-attachments/assets/7d3b50dc-61e3-49c7-8eb1-dfe9d04cf0f8)

1. **Initiative Tracker:** Keeps track of the order the characters will take their turn in. Also indicates the current active character.
2. **Summon Pool:** Indicates the amount of wisps on standby that are available to be used for summoning.
3. **Player Characters Summary:** Displays the current health of all player characters (May want to include some statuses and wisp pool).
4. **Active Player Details:** Displays the current active player character along with their health and wisp pool.
5. **Enemy Summary:** Displays the health and portrait of the enemy that is being highlighted by the Tile Selector. Only appears when an enemy is highlighted.
6. **Player Options:** Only active during a player character's turn. Displays a set of options the user can take for the player. These options are "Technique", "Spell", "Summon", "Item", and "End".
7. **Action Options:** Only active during a player character's turn. Displays a set of options for a selected "Technique", "Spell", "Summon", or "Item" action.
8. **Tile Selector:** Highlights the map tile that will be used for various player character actions (movement, etc.).

### Character Details

A menu that provides full descriptions about the stats and abilities of both players and enemies. It is split into two interfaces, one for player characters and one for enemy characters. The interface swaps between player and enemy detail menus.

![Player_Details_UI](https://github.com/user-attachments/assets/06d525b7-ef88-405a-97fb-c04b184f0dc3)

1. **Player Character Selector:** Area for selecting other player characters for detailed view.
2. **Player Sprite Display:** Detailed Player sprite.
3. **Wisp Pool:** The currently allocated wisps and their set status. Can hover over to select specific wisp to see popup of benefits granted.
4. **Spells & Techniques:** Lists of spells and techniques the player currently has access to.
5. **Player Statistics:** Collection of all player stats.
6. **Item Pouch:** List of items allocated to the player.
7. **Enemy Character Selector:** Area for selecting enemy characters for detailed view.

![Enemy_Details_UI](https://github.com/user-attachments/assets/70b35bcc-3fa8-476f-a965-395abf23502b)

1. **Enemy Character Selector:** Area for selecting other enemy characters for detailed view.
2. **Enemy Sprite Display:** Detailed Enemy sprite.
3. **Enemy Bio Display:** Flavor text describing the enemy.
4. **Enemy Statistics:** Collection of all enemy stats.
5. **Enemy Actions:** Collection of actions the enemy is able to execute. Listed in inverse order of priority.
6. **Player Character Selector:** Area for selecting player characters for detailed view.

The elemental alignment of player characters, the summon pool, and other elementally affected aspects is indicated by a specific GUI element. These are some examples of what the GUI might look like.
- *Note: The GUI element should use a hexagram as a key component of its design.*

![Element_Alignment_Display](https://github.com/user-attachments/assets/d91d9ee7-6797-439e-ad62-b8a15a9629da)

## Diegetics

When outside of combat, environmental elements that the player can interact with should be obvious.
- Interactable elements could follow the same visual patterns, or just be the same object.
- Elements could have visual cues, such as movement or particle effects, that draw the player's attention.

## Integration

# Market Requirements

## Priorities

## Minimum Viable Product

## Delivery

## Marketing

## Post-Launch

# Technical Requirements

## Items

Items are not fully "consumable" as they are intended to refresh after a combat encounter. Need to decide how acquiring new consumable items works.

An upgrade system is needed to allow for the expanding of the use of items.
- Increasing the number of items that a player can bring in (increasing item slots).
- Incresing the number of a single item a player can place in a single item slot.
- Unlocking new items that can be brought in to battle.

## Weapon Mastery

Weapons can be mastered by characters, which will allow for special techniques locked to specific weapons to be able to be used when a character wields a different weapon of the same type. Need to determine what other benefits weapon mastery grants.
- Allowing for "general" techniques to be used across all weapons.
- Increasing weapon damage or adding a crit chance.

## Status Effects

Need to build a system that allows for status effects to be applied by actions.
- Needs to be able to specify if characters or tiles are affected.
- Needs to be able to describe if an afflicted enemy character should use a different behaviour.
- Needs to allow for the modular customization of status effects.
    - Most status effects should be created by the changing of parameters instead of implementing specialized logic for each status.

## Biomes and Random Encounters

Areas of the overworld map will be separated into distinct "biomes", each having their own distinct set of creatures to draw from for the purposes of determining random encounters.
- The creatures associated with each biome will be categorized as either "Predator", "Prey" or "Monster".
- A biome will passively track the percentage distribution of each creature category, simulating an ecosystem.
  - Prey percentage will grow inversly to Predator percentage.
  - Monster percentage increase will lower both Predator and Prey.
  - A successful random encounter with Monster creatures will lower the Monster percentage.
- The enemy characters and map used for the encounter will be determined as the user traverses the world map.
  - The encounter will use a random tile map from a predifined set specific to the biome.

## Character Stats

Both enemy and player characters have a collection of stats that determine their strength and capabilities in combat:
- Affinity: Indicates the primary elemental affinity of the character. Can be earth, fire, water, wind, or some combination of the four.
- Level: A value that determines the value of all other stats.
- Health: The maximum vitality of the character.
- Attack: Determines the strength of offensive actions.
- Defense: Determines the amount of damage that is mitigated from offensive actions.
- Agility: The primary stat for determining a character's order in initiative.
- Magic: Determines the bonus strength of an action based off the action's elemental alignment.
  - This stat is further broken down into four aspects: earth, fire, water, and air. Each aspect has its own distinct value.
- Resistance: Determines the amount of damage mitigated from the bonus strength of offensive actions.
  - This stat is further broken down into four aspects: earth, fire, water, and air. Each aspect has its own distinct value.

## Action Potency

Actions have a potency value that determines what percentage of the character's attack the action uses to determine its strength. For example, the "Strike" action could have a potency of 50, meaning that if this action was used by a character with 500 attack (factored in for level), the action would have a strength of 250.

All actions have an elemental affinity that is determined by a variety of factors. An action can have multiple elemental affinities of different values. For example, an action "Torrent" could have an elemental affinity of 2 water while an action "Dust Devil" could have an elemental affinity of 1 earth and 2 wind. By default, all actions have an elemental affinity of 1, with the element being the affinity of the character using the action. These affinity values determine the potency of the element, which defines the percentage value of the corresponding magic stat to add to the strength of the action.

| Affinity value | Bonus Potency |
| --- | --- |
| 1 | 100 |
| 2 | 150 |
| 3 | 200 |
| 4 | 233 |
| 5 | 263 |
| 6 | 300 |

Defense is subtracted from the strength of the action, while each resistance type is subtracted from the relevant bonus strength. The resulting values are then added together to determine the amount of damage that is dealt.
