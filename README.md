# custom-chat
Chat for FiveM with some roleplay command such as /b /me /me /clear /ame or /pm

## Features
```
/b - Local OOC Chat
/me - Text
/do - Text
/ame - Same As /me But Display As The Bubble Above Your Head
/pm - Private Message To Other Player Or Yourself
/pmconfig - For Admin To Config PM As You Want
/clear - Clear The Chat
```

## Exports 
```
exports['custom-chat']:SendClientMessage(target, msg)
exports['custom-chat']:SetPlayerChatBubble(target, msg, color, range, duration)
```

## Install
If you are using QBCore just go into your server.cfg and set "set resources_useSystemChat" to false and unensured the original chat. Then just add this "ensure custom-chat"

## Preview
![preview](https://cdn.discordapp.com/attachments/1300094726179000491/1413301927621558443/Screenshot_2025-09-05_060439.png?ex=68d281bd&is=68d1303d&hm=3ec4ced750c27fdff30f6fbbc1972740ae0b6e87fa5edccf291aee6ee0f8ed6f&)
