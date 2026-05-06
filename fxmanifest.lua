fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'NoCtrl Studios'
description 'Qbox Stripper Pole Script'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'ox_target',
    'ox_lib',
    'ox_inventory',
    'qbx_core'
}
