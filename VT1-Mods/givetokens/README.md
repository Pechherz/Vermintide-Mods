<p align="center">
  <img src="../../../assets/banner-top.png" width="1080" alt="">
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
/givetokens <token name> <number of tokens>
```

The first parameter (**string**) is the *token name* and there are four of them available:
1. iron_tokens <img src="../../../assets/Mod-Material/givetoken/white_token.png" alt="(white token)" title="Iron Token" width="20">
2. bronze_tokens <img src="../../../assets/Mod-Material/givetoken/green_token.png" alt="(green token)" title="Bronze Token" width="20">
3. silver_tokens <img src="../../../assets/Mod-Material/givetoken/blue_token.png" alt="(blue token)" title="Silver Token" width="20">
4. gold_tokens <img src="../../../assets/Mod-Material/givetoken/orange_token.png" alt="(orange token)" title="Gold Token" width="20">

The second parameter (**number**) is the *number of tokens*, which requires a positive number as input. 

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
  <img src="../../../assets/banner-buttom.png" width="1080" alt="">
</p>
