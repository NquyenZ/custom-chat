# custom-chat
A custom chat for FiveM inspired by SA-MP with such as some roleplay commands

## Optional Requirement
[dvn-typing](https://github.com/devindevelopments/dvn-typing) - For Typing Indicator

But if you don't want to use this just go to 'client.lua' and delete these lines 

```
TriggerEvent("dvn-typing:input", true)
TriggerEvent("dvn-typing:input", false)
```

## Features
```
/b - Local OOC chat
/me - Text
/do - Text
/ame - Same as '/me' but it will display above your head
/pm - Private message to other player or yourself
/pmconfig - For admin to config PM feature
/clear - Clear your chat box
```

## Exports 
```
exports['custom-chat']:SendClientMessage(target, msg)
TriggerServerEvent('custom-chat:showBubble', target, msg, color, range, duration)
```

## Install
Just go into your server.cfg and set "set resources_useSystemChat" to false and unensured the original chat. Then just add this line "ensure custom-chat"

## Preview
![preview](https://cdn.discordapp.com/attachments/1300094726179000491/1413301927621558443/Screenshot_2025-09-05_060439.png?ex=68fa0ebd&is=68f8bd3d&hm=3ff9f8441fa88d7d590fc8ac626fcb194501f6e7f9055a58f0e8d850f2327a19&)
