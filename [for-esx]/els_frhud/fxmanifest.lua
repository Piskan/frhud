
fx_version 'cerulean'
games { 'rdr3', 'gta5' }

author 'ByPislik'
description 'elastik sirket'
version '1.0.0'




ui_page 'html/index.html'


files {
    'html/index.html',
    'html/*.js',
    'html/vehicleicons/*.svg',
    'html/weaponicons/*.png'
}




client_scripts {
    'config.lua',
    'client.lua'
}
server_script {
    'config.lua',
    'server.lua'

}

