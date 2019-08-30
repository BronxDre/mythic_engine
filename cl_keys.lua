local isLoggedIn = false
local lockCd = false
local LockedCars = {}
local Keys = {}

function HasKeys(license)
    if license == nil then return end
    return Keys[license] ~= nil
end

function GetKeys(license, hideAlert)
    if license == nil then return end

    if not hideAlert then
        exports['mythic_notify']:SendAlert('inform', 'You Recieved Keys To A Vehicle')
    end
    
    Keys[license] = true
end

function TakeKeys(license)
    if license == nil then return end
    exports['mythic_notify']:SendAlert('inform', 'You Had Keys To A Vehicle Taken')
    Keys[license] = nil
end

RegisterNetEvent('mythic_engine:client:SyncLocks')
AddEventHandler('mythic_engine:client:SyncLocks', function(cars)
    LockedCars = cars
end)

RegisterNetEvent('mythic_base:client:Logout')
AddEventHandler('mythic_base:client:Logout', function()
    isLoggedIn = false
end)

RegisterNetEvent('mythic_base:client:CharacterSpawned')
AddEventHandler('mythic_base:client:CharacterSpawned', function()
    isLoggedIn = true

    local player = PlayerPedId()

end)

function CheckVehicle()
    local player = PlayerPedId()
    local plyCoords = GetEntityCoords(player, true)
    local rayHandle = StartShapeTestCapsule(plyCoords.x, plyCoords.y, plyCoords.z, plyCoords.x, plyCoords.y, plyCoords.z, 50.0, 2, 0, 0)
    local a, b, c, d, veh = GetShapeTestResult(rayHandle)

    if veh ~= 0 then
        local plate = GetVehicleNumberPlateText(veh)
        if DecorExistOn(veh, 'HasFakePlate') then
            plate = exports['mythic_garages']:TraceBackPlate(plate)
        end
        if Keys[plate] then
            return veh, plate
        else
            return nil
        end
    else
        return nil
    end
end

function loadAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		RequestAnimDict(dict)
		Citizen.Wait(100)
	end
end

Citizen.CreateThread(function()
    while true do
        if IsControlJustReleased(1, 303) then
            if not lockCd then
                local veh, plate = CheckVehicle()
                if veh then
                    loadAnimDict( "anim@mp_player_intmenu@key_fob@" )
                    lockCd = true
                    if LockedCars[plate] then
                        LockedCars[plate] = nil
                        SetVehicleDoorsLocked(veh, 1)
                        TriggerServerEvent('mythic_engine:server:UpdateVehLock', plate, nil)
                        exports['mythic_notify']:SendAlert('inform', 'Vehicle Unlocked')
                        
                        Citizen.CreateThread(function()
                            SetVehicleLights(veh, 2)
                            Citizen.Wait(250)
                            SetVehicleLights(veh, 0)
                            Citizen.Wait(250)
                            SetVehicleLights(veh, 2)
                            Citizen.Wait(250)
                            SetVehicleLights(veh, 0)
                        end)
                    else
                        LockedCars[plate] = true
                        SetVehicleDoorsLocked(veh, 2)
                        TriggerServerEvent('mythic_engine:server:UpdateVehLock', plate, true)
                        exports['mythic_notify']:SendAlert('inform', 'Vehicle Locked')
                        Citizen.CreateThread(function()
                            SetVehicleLights(veh, 2)
                            Citizen.Wait(500)
                            SetVehicleLights(veh, 0)
                        end)
                    end

                    if not IsPedInAnyVehicle(PlayerPedId(), true) then
                        TaskPlayAnim(PlayerPedId(), 'anim@mp_player_intmenu@key_fob@', 'fob_click', 2.0, 2.5, -1, 48, 0, 0, 0, 0 )
                    end
                    TriggerServerEvent('mythic_sounds:server:PlayWithinDistance', 10.0, 'carlock', 0.05)
                    Citizen.Wait(1000)
                    lockCd = false
                    RemoveAnimDict('anim@mp_player_intmenu@key_fob@')
                else
                    Citizen.Wait(1000)
                end
            else
                Citizen.Wait(100)
            end
        end
        Citizen.Wait(1)
    end
end)