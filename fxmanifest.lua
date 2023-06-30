fx_version 'adamant'
games { 'gta5' }
author 'Misha#0460 =)'
client_scripts {
    "client/*.lua",
    "config.lua"
}

server_scripts {
    "server/*.lua",
    '@oxmysql/lib/MySQL.lua',
    "config.lua"
}

shared_scripts {
    "@es_extended/imports.lua",
}