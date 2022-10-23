<p align="center">
  <img src="../../../assets/banner-top.png" width="1080">
</p>

## Description:
This is a chat command to add upgrade tokens to the inventory, which are used in the process of rerolling and gambling to improve the traits of a weapon.

## Installation:
- download and unzip the [givetokens.zip](../../../../releases/tag/givetokens) archive
- copy *givetokens.lua* to \SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\commands\
- add the following line to the file \SteamLibrary\steamapps\common\Warhammer End Times Vermintide\binaries\mods\CommandList.lua: 
`{ "/givetokens", true, "commands", "givetokens" },`

## How to use:  
There are only two parameters the command requires in order to add upgrade tokens to the inventory.  
```
/givetokens <token type> <non-zero number>
```

The first parameter is the token type and there are four of them available:
1. iron_tokens (white tokens)
2. bronze_tokens (green tokens)
3. silver_tokens (blue tokens)
4. gold_tokens (orange tokens)

The second parameter is the amount of tokens, which requires a natural number as input. 

The following example will add 30 white tokens to the player inventory.
```
/givetokens iron_tokens 30
```

## Note:
Refer to the following help command to get ingame information:
```
/givetokens help
```

<br/>

<p align="center">
  <img src="../../../assets/banner-buttom.png" width="1080">
</p>
