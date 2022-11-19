<p align="center">
  <img src="../../../assets/banner-top.png" alt="" width="1080">
</p>

## Description:
This is a simple chat command to load any map.

## Installation:
- download and unzip the [loadmap.zip](../../../../releases/tag/loadmap) archive
- copy *loadmap.lua* to \SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch\
- add the following line to the file \SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\CommandList.lua:
`{ "/loadmap", true, "commands", "loadmap" },`

## How to use:  
There are only two parameters available to provide them to the chat command. However the second parameter ```difficulty id``` is optional.
```
/loadmap <map id> <optional difficulty id>
```  

The **first parameter** is for the map id and there are 28 available including the ones from the DLCs:  
1. inn_level (Red Moon Inn)
2. magnus (The Horn of Magnus)
3. merchant (Supply and Demand)
4. sewers_short (Smuggler's Run)
5. wizard (The Wizard's Tower)
6. dlc_challenge_wizard (Trial of the Foolhardy)
7. bridge (Black Powder)
8. forest_ambush (Engines of War)
9. city_wall (Man the Ramparts)
10. cemetery (Garden of Morr)
11. farm (Wheat and Chaff)
12. tunnels (The Enemy Below)
13. courtyard_level (Well Watch)
14. docks_short_level (Waterfront)
15. end_boss (The White Rat)
16. chamber (Waylaid)
17. dlc_survival_magnus (Town Meeting)
18. dlc_dwarf_interior (Khazid Kro - Karak Azgaraz DLC)
19. dlc_dwarf_exterior (The Cursed Rune - Karak Azgaraz DLC)
20. dlc_dwarf_beacons (Chain of Fire - Karak Azgaraz DLC)
21. dlc_castle (Castle Drachenfels - Drachenfels DLC)
22. dlc_castle_dungeon (The Dungeons - Drachenfels DLC)
23. dlc_portals (Summoner's Peak - Drachenfels DLC)
24. dlc_reikwald_river (The River Reik - Death on the Reik DLC)
25. dlc_reikwald_forest (Reikwald Forest - Death on the Reik DLC)
26. dlc_stromdorf_hills (The Courier - Stromdorf DLC)
27. dlc_stromdorf_town (Reaching Out - Stromdorf DLC)
28. dlc_survival_ruins (The Fall - Schluesselschloss DLC)  

The **second parameter** is for the difficulty id and **optional**.  
There are five difficulties for campaign missions.
1. easy (Easy)
2. normal (Normal)
3. hard (Hard)
4. harder Nightmare)
5. hardest (Cataclysm)  

For survival missions there are different difficulties available.
1. survival_hard (Veteran)
2. survival_harder (Champion)
3. survival_hardest (Heroic)

The following example would load 'The Horn of Magnus' on Nightmare:
```
/loadmap magnus harder
```

Load Lohner's tavern
```
/loadmap inn_level
```

Load Town Meeting on Heroic
```
/loadmap dlc_survival_magnus survival_hardest
```

## Note:
Refer to the following help command to get ingame information:
```
/loadmap help
```

<br/>

<p align="center">
  <img src="../../../assets/banner-buttom.png" alt="" width="1080">
</p>
