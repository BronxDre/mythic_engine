local LockedCars = {}

RegisterServerEvent('mythic_base:server:CharacterSpawned')
AddEventHandler('mythic_base:server:CharacterSpawned', function()
    TriggerClientEvent('mythic_keys:client:SyncLocks', source, LockedCars)
end)

RegisterServerEvent('mythic_keys:server:UpdateVehLock')
AddEventHandler('mythic_keys:server:UpdateVehLock', function(plate, state)
    LockedCars[plate] = state
    TriggerClientEvent('mythic_keys:client:SyncLocks', -1, LockedCars)
end)