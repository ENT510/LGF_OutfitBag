fx_version 'cerulean'
game 'gta5'
version '1.0.2'
lua54 'yes'
author 'ENT510'

shared_scripts {
  '@ox_lib/init.lua',
}

client_scripts {
  'Modules/Client/cl-constructor.lua',
  'Modules/Client/cl-cam.lua',
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'Modules/Server/sv-functions.lua',
  'Modules/Server/sv-main.lua',
}

files {
  'Modules/Client/cl-config.lua',
  'Modules/Shared/shared.lua',
}

