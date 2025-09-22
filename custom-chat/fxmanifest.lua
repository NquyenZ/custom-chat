fx_version 'cerulean'
game 'gta5'

author 'nquyenZ'
description 'FiveM chat with some roleplay command'
version '1.0.1'

shared_scripts
{
    'config.lua'
}

ui_page 'html/index.html'

files
{
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/RobotoCondensed-Bold.ttf'
}

client_scripts
{
    'client.lua'
}

server_scripts
{
    'server.lua'
}

exports
{
    'SendClientMessage',
    'SetPlayerChatBubble'
}
