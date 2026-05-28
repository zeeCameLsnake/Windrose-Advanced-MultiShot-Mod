# Windrose - Advanced MultiShot Mod

A Lua-based mod for the game **Windrose** (Unreal Engine 5.6) that enhances *advanced* ranged weapons by giving them the `MultiShotAbility` and dynamically scaling their clip sizes.

## Features
* **Multi-Shot Ability:** Swaps the standard single-shot mechanic with a multi-shot ability for supported advanced ranged weapons.
* **Dynamic Clip Size Scaling:** Automatically upgrades weapon clip sizes based on their vanilla stats to ensure balanced progression:
  * 1 Shot -> Upgraded to 2 Shots
  * 2 Shots -> Upgraded to 3 Shots
  * 3+ Shots -> Upgraded to 5 Shots
* **Vanilla Reloading:** Maintains the original reload values (e.g., loading 1 shot per reload cycle) to preserve game balance despite the increased clip sizes.
* **Full Co-op / Multiplayer Support:** Fully compatible with multiplayer sessions. The mod automatically monitors the server and applies weapon upgrades the exact moment they are loaded into memory, requiring no manual hotkeys.

## Supported Weapons (Advanced Variants)
* **Pistols:** Corrupted, Drake's Doom, Reliable
* **Blunderbuss:** Dragonbreath, Reliable
* **Muskets:** Infantry, Reliable, Sniper

## Installation
1. Ensure you have the appropriate Lua mod loader installed (e.g., UE4SS).
2. Make sure your UE4SS-settings.ini uses the proper engine version:  
<pre>                        [EngineVersionOverride]  
                        MajorVersion = 5  
                        MinorVersion = 6 </pre>   
3. -`Singleplayer:` Drop the ***(unpacked)*** mod folder into your `Mods` directory [**Windrose \ R5 \ Binaries \ Win64 \ ue4ss \ Mods**].  
   -`Multiplayer:` The host needs to install it at [**Windrose \ R5 \ Builds \ WindowsServer \ R5 \ Binaries \ Win64 \ ue4ss  \ Mods**].  
   -`Dedicated Server:` ***NOT TESTED YET!*** If you tried it (successfully or not) -> reporting your results in the comments is appreciated.   
4. Start the game. The mod initializes automatically upon entering a level.

## Design Decisions & Development Notes
During development, an update to the "Ascension" UI (to visually reflect the new clip sizes in the crafting menus) was planned. However, after extensive technical analysis, this feature was deliberately discarded for the following reasons:
* **Maintainability:** Modifying the UI required hardcoding paths to specific text `DataAssets` for every single weapon variant. Since the game is currently in Early Access, these asset paths and UI structures are highly susceptible to change in future patches.
* **Architecture over Cosmetics:** The core gameplay logic (the `MultiShotAbility` and dynamically scaling clip sizes) is implemented abstractly and robustly, allowing it to survive most game updates without maintenance. Tying this clean logic to fragile UI widget modifications would have compromised the stability of the entire mod.
* **Shifted Focus:** As a result, project resources were shifted entirely towards delivering a bulletproof **Multiplayer/Co-op integration** (using UE4SS's `NotifyOnNewObject` hook), ensuring a seamless gameplay experience instead of minor cosmetic changes.


## Credits  
Shout out to the crew at `Kraken Express`, who developed this -already great- game, which inspired me to finally start modding.    

## Author
Created by `zeeCameLSnake`.