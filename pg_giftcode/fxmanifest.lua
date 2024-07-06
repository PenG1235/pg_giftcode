fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'PenG - PG Scripts'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

client_scripts {
    'client/client.lua'
}