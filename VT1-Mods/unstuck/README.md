<p align="center">
  <img src="../../../assets/banner-top.png" width="1080">
</p>

## Description:
A simple chat command to unstuck the player.

## Installation:
- copy *unstuck.lua* to ..\SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch\
- add the following line to the file \SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\CommandList.lua: 
`{ "/unstuck", false, "commands", "unstuck" },`

## How to use:
If the player happens to get stuck somewhere on a map, simply type following line into the chat box:
```
/unstuck
```  
This moves the player onto walkable ground. 

## Note:
Currently only the hosting player can unstuck himself due to navmesh being only generated server side.

<br/>

<p align="center">
  <img src="../../../assets/banner-buttom.png" width="1080">
</p>
