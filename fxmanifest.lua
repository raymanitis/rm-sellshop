-- Resource Metadata
fx_version 'bodacious'
lua54 'yes'
game 'gta5'

author 'Raymans'
description 'Sell shop script by raymans'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}
