fx_version 'cerulean'
game 'gta5'

author 'nquyenZ'
description 'FiveM Chat'
version '1.3'

shared_scripts
{
    'config.lua'
}

ui_page
{
    'html/index.html'
}

files
{
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/fonts/lato.semibold.ttf'
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
}
