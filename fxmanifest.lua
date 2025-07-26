fx_version 'cerulean'
game 'gta5'

author 'TonNom'
description 'HUD Moderne Faim & Soif'
version '1.0.0'

shared_script '@es_extended/imports.lua'
shared_script 'config.lua' -- ✅ AJOUT ICI

client_script 'client.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'index.html'

files {
    'index.html',
    'style.css',
    'script.js',
     'alcohol.svg',
    'hunger.svg',
    'water.svg'
}
