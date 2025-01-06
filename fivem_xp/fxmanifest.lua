fx_version 'cerulean'
game 'gta5'

author '77killer'
description 'XP System for QBCore Framework'
version '1.0.0'

-- Shared Scripts
shared_scripts {
    'config.lua'              -- Configuration file (if applicable)
}

-- Client Scripts
client_scripts {
    'client/main.lua'         -- Your client-side script
}
-- Server Scripts
server_scripts {
    '@oxmysql/lib/MySQL.lua', -- OxMySQL library
    'server/main.lua'         -- Your server-side script
}
-- Dependencies
dependencies {
    'qb-core',
    'oxmysql',
    'ox_inventory'
}

lua54 'yes' -- Ensure compatibility with Lua 5.4
