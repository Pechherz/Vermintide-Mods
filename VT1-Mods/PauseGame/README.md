<p align="center">
  <img src="../../../assets/banner-top.png" width="1080">
</p>

## Description:
This mod allows pausing the game on a key press.  

When a host pauses the game, then all clients including the host and the game will freeze.  
If a client attempts to pause the game, then only the client will be paused while the other peers won't be affected.  
The said client will perceive the world to be paused, but in actuallity its only causes a client side desync.

Mod options are found under *Shenanigans*.

## Installation:
- download and unzip the [PauseGame.zip](../../../../releases/tag/PauseGame) archive
- copy *PauseGame.lua* to \SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch\
- copy *pause_game.lua* to \SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\patch\action\

## Note:
Do **NOT** click on any button in the main menu while the game is paused, otherwise you'll be stuck there.  

If your game doesn't pause properly after pressing a key, then there might be a conflict with an outdated version of DisconnectResilience.lua.  
You can either put the file DisconnectResilience.lua within a subfolder to disable it once the game is restarted or  
update your file with a [compatible version](./optional/DisconnectResilience.lua).

<br/>

<p align="center">
  <img src="../../../assets/banner-buttom.png" width="1080">
</p>
