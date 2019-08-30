local LockedCars = {}

RegisterServerEvent('mythic_base:server:CharacterSpawned')
AddEventHandler('mythic_base:server:CharacterSpawned', function()
    TriggerClientEvent('mythic_engine:client:SyncLocks', source, LockedCars)
end)

RegisterServerEvent('mythic_engine:server:UpdateVehLock')
AddEventHandler('mythic_engine:server:UpdateVehLock', function(plate, state)
    LockedCars[plate] = state
    TriggerClientEvent('mythic_engine:client:SyncLocks', -1, LockedCars)
end)