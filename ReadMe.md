# TubTalents V2
![screenshot](https://i.imgur.com/mgueUqO.png)
* Talent Previews - Move points around without commiting
* Talent Presets - Save staged or learned talents for later
* Levelling Plans - Make a plan in Sim Mode, and automatically learn talents as you level
* Sim mode - Allows experimenting with staged points without resetting talents. Maximum points is customizable
* Shift click talent links in chat
* Minimap button and slash command open talent frame even if you're under level 10
* Sharing presets/plans in game and externally with import/export functionality
* Be sure to only import from people you trust
* *In theory* works on both Vanilla and Custom servers. Tested on Vanilla Repack, and Wallcraft. More info in [limitations](#Limitations)
* Supports pfUI

# *SPECIAL THANKS TO*: 
* [Reliquary](https://github.com/The-Kludge-Bureau/Reliquary) by [The Kludge Bureau](https://github.com/The-Kludge-Bureau) querying DBCs for talents SpellIDs
* [SuperWoW](https://github.com/balakethelock/SuperWoW#instructions) by [balakethelock](https://github.com/balakethelock/) tooltips and shift click links.
* Shagu, Wall, Brotalnia

# Commands: 
* `/tubtalents` displays help
* `/tubtalents catchup` catchs up with current levelling plan if a valid plan is selected
* `/tubtalents minimap` shows/hides the minimap button
* `/tubtalents reset` resets all settings, plans and presets with confirmation
* `/tubtalents toggle` shows/hides the talent frame. Even if you're under level 10

# Installation:
0. Install [SuperWoW](https://github.com/balakethelock/SuperWoW#instructions) and [Reliquary](https://github.com/The-Kludge-Bureau/Reliquary) client mods. Both can be added to `dlls.txt` for [VanillaFixes](https://github.com/hannesmann/vanillafixes/releases). Will still function at a limited capacity without client mods. (tooltips won't update for staged points, no shift click links)
1. Click the Code button to the upper right hand corner and select download or click [here](https://github.com/tubtubs/TubTalents/archive/refs/heads/master.zip).
2. Unzip the download into your Interface/Addons folder in your WoW directory. Eg: *C:\Games\WoW\Interface\Addons*
3. Rename the folder from *TubTalents-master* to *TubTalents*
4. Restart WoW and enable the addon from the character selection screen. Ensure your addon memory cap is set to 0 (no limit) or a high number like 256.

You can also use the [GitAddonsManager](https://gitlab.com/woblight/GitAddonsManager) to install this addon, but it will not install the required client mods.

* If there are any further issues with installation, ensure that *TubTalents.toc* is in the root folder. There should be no subdirectories. Eg: *C:\Games\WoW\Interface\Addons\TubTalents\TubTalents.toc*

# Limitations
* Talent Points start at level 10
* 1 talent point per level
* 3 talent tabs
* Can only import presets/plans for your class
* Levelling plans must start at level 10
* Levelling plans can only be created in sim mode, without loading presets
* Selected levelling plans except stright adherence, knowing talents not in the plan will deselect the levelling plan and won't allow you to select it until you reset talents

# Conflicts
This addon replaces many of the calls relating to talent info, so staged talent points are considered. This will likely cause issues for other addons handling talents

# ChangeLog
## New in V2
* Levelling Plans
* Export/Import of Plans and Presets
* In game Addon Message sharing of Plans and Presets
* Levelling plan catchup and reset slash commands
* More settings + debug modes
* Some pfUI support