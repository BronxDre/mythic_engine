resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

name 'Mythic Engine'
description 'Engine Resource That Also Handles Hotwiring'
author 'Alzar - https://github.com/Alzar'
version 'v1.0.0'
url 'https://github.com/mythicrp/mythic_engine'

client_scripts {
	'sh_config.lua',
	'cl_main.lua',
	'cl_keys.lua',
}

server_scripts {
	'sv_keys.lua',
}

dependencies {
    'mythic_base',
}

exports {
	-- Lockpick Timers
	'GetLockpickTimers',

	-- Engine
	'Hotwire',
	'IsCarHotwired',
	'OutOfFuel',
	'Refueled',
	'IsVehFueled',

	--Keys
	'HasKeys',
	'GetKeys',
	'TakeKeys',
}