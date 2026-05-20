# TubTalents
* Talent Previews - Move points around without commiting
* Talent Presets - Save staged or learned talents for later
* Shift click talent links in chat
* Sim mode - Allows experimenting with staged points without resetting talents. Maximum points is customizable
* Minimap button and slash command open talent frame even if you're under level 10
* *In theory* works on both Vanilla and Custom servers. Tested on Vanilla Repack, and Wallcraft

*SPECIAL THANKS TO CLIENT MODS*: This addon makes use of DBC Query methods provided by [Reliquary](https://github.com/The-Kludge-Bureau/Reliquary), allowing SpellID lookups to provide [SuperWoW](https://github.com/balakethelock/SuperWoW#instructions) tooltips and shift click links.

# Commands: 
* `/tubtalents` displays help
* `/tubtalents toggle` shows/hides the talent frame. Even if you're under level 10
* `/tubtalents minimap` shows/hides the minimap button

# Installation:
0. Install [SuperWoW](https://github.com/balakethelock/SuperWoW#instructions) and [Reliquary](https://github.com/The-Kludge-Bureau/Reliquary) client mods. Both can be added to `dlls.txt` for [VanillaFixes](https://github.com/hannesmann/vanillafixes/releases). Will still function at a limited capacity without client mods. (tooltips won't update for staged points, no shift click links)
1. Click the Code button to the upper right hand corner and select download or click [here](https://github.com/tubtubs/TubTalents/archive/refs/heads/master.zip).
2. Unzip the download into your Interface/Addons folder in your WoW directory. Eg: *C:\Games\WoW\Interface\Addons*
3. Rename the folder from *TubTalents-master* to *TubTalents*
4. Restart WoW and enable the addon from the character selection screen. Ensure your addon memory cap is set to 0 (no limit) or a high number like 256.

You can also use the [GitAddonsManager](https://gitlab.com/woblight/GitAddonsManager) to install this addon, but it will not install the required client mods.

* If there are any further issues with installation, ensure that *TubTalents.toc* is in the root folder. There should be no subdirectories. Eg: *C:\Games\WoW\Interface\Addons\TubTalents\TubTalents.toc*

# Conflicts
This addon replaces many of the calls relating to talent info, so staged talent points are considered. This will likely cause issues for other addons handling talents