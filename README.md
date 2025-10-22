# custom-chat
Chat for FiveM with some roleplay command such as /b /me /me /clear /ame or /pm

## Optional Requirement
[dvn-typing](https://github.com/devindevelopments/dvn-typing) - For Typing Indicator

But if you don't want to use this just go to 'custom-chat/client.lua:16' and 'custom-chat/client.lua:62' and delete these lines 

```
TriggerEvent("dvn-typing:input", true)
TriggerEvent("dvn-typing:input", false)
```

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
TriggerServerEvent('custom-chat:showBubble', target, msg, color, range, duration)
```

## Install
Just go into your server.cfg and set "set resources_useSystemChat" to false and unensured the original chat. Then just add this "ensure custom-chat"

## Preview
![preview](https://cdn.discordapp.com/attachments/1300094726179000491/1413301927621558443/Screenshot_2025-09-05_060439.png?ex=68fa0ebd&is=68f8bd3d&hm=3ff9f8441fa88d7d590fc8ac626fcb194501f6e7f9055a58f0e8d850f2327a19&)
