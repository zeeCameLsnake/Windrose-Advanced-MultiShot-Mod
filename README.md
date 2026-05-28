# Windrose - Advanced MultiShot Mod

A Lua-based mod for the game **Windrose** (Unreal Engine 5.6) that enhances *advanced* ranged weapons by giving them the `MultiShotAbility` and dynamically scaling their clip sizes.

## Features
* **Multi-Shot Ability:** Swaps the standard single-shot mechanic with a multi-shot ability for supported advanced ranged weapons.
* **Dynamic Clip Size Scaling:** Automatically upgrades weapon clip sizes based on their vanilla stats to ensure balanced progression:
  * 1 Shot -> Upgraded to 2 Shots
  * 2 Shots -> Upgraded to 3 Shots
  * 3+ Shots -> Upgraded to 5 Shots
* **Vanilla Reloading:** Maintains the original reload values (e.g., loading 1 shot per reload cycle) to preserve game balance despite the increased clip sizes.

## Supported Weapons (Advanced Variants)
* **Pistols:** Corrupted, Drake's Doom, Reliable
* **Blunderbuss:** Dragonbreath, Reliable
* **Muskets:** Infantry, Reliable, Sniper

## Installation
1. Ensure you have the appropriate Lua mod loader installed (e.g., UE4SS).
2. Make sure your UE4SS-settings.ini uses the proper engine version:  
                `[EngineVersionOverride]`  
                `MajorVersion = 5`  
                `MinorVersion = 6`    
3. Drop the mod folder into your `Mods` directory [**Windrose \ R5 \ Binaries \ Win64 \ ue4ss \ Mods**].
4. Start the game. The mod initializes automatically upon entering a level.

## Planned Features (TODOs)
* **Ascension UI Update:** Modify the UI text during the weapon "Ascension" process (Basic to Advanced) to accurately reflect the upgraded clip sizes in the menu.
* **Co-op / Multiplayer Support:** Investigate and implement full compatibility to ensure the mod works correctly and syncs properly for all players in a multiplayer session.

## Credits  
Shout out to the crew at `Kraken Express`, who developed this -already great- game, which inspired me to finally start modding.    

## Author
Created by `zeeCameLSnake`.