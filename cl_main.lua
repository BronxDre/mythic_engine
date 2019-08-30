local EngineKey = 56
local HotwireKey = 20
local SearchKey = 58
local vehicles = {}
local isToggling = false
local canHotwire = false

local canAttemptHotwire = true
local isAttemptingHotwire = false
local canSearchForKey = true
local isSearching = false

function Print3DText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)

    if onScreen then
        local px, py, pz = table.unpack(GetGameplayCamCoords())
        local dist = #(vector3(px, py, pz) - vector3(coords.x, coords.y, coords.z))    
        local scale = (1 / dist) * 20
        local fov = (1 / GetGameplayCamFov()) * 100
        local scale = scale * fov   
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(250, 250, 250, 255)		-- You can change the text color here
        SetTextDropshadow(1, 1, 1, 1, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        SetDrawOrigin(coords.x, coords.y, coords.z, 0)
        DrawText(0.0, 0.0)
        ClearDrawOrigin()
    end
end

RegisterNetEvent('mythic_engine:client:PlayerEnteringVeh')
AddEventHandler('mythic_engine:client:PlayerEnteringVeh', function(veh)
    Citizen.CreateThread(function() 
        while IsVehicleNeedsToBeHotwired(veh) do
            Citizen.Wait(0)
            local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
            SetVehicleNeedsToBeHotwired(veh, false)
        end
    end)
end)

RegisterNetEvent('mythic_engine:client:StartEngineListen')
AddEventHandler('mythic_engine:client:StartEngineListen', function()
    Citizen.CreateThread(function()
        canAttemptHotwire = true
        isAttemptingHotwire = false
        canSearchForKey = true
        isSearching = false

        while IsPedInAnyVehicle(PlayerPedId()) do
            Citizen.Wait(0)
            if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
                if IsControlJustReleased(1, EngineKey) then
                    if not isToggling then
                        isToggling = true
                        SetEngineState()
                    end
                elseif IsControlJustReleased(1, HotwireKey) and canHotwire and canAttemptHotwire and not isSearching then
                    canAttemptHotwire = false
                    isAttemptingHotwire = true
                    AttemptHotwire(GetVehiclePedIsIn(PlayerPedId()), 65, (Config.Stages + 1), 25)
                elseif IsControlJustReleased(1, SearchKey) and canHotwire and canSearchForKey and not isAttemptingHotwire then
                    canSearchForKey = false
                    isSearching = true
                    SearchForKey(GetVehiclePedIsIn(PlayerPedId()), 35, 25)
                end
                
                local ped = PlayerPedId()

                if GetSeatPedIsTryingToEnter(ped) == -1 and not table.contains(vehicles, GetVehiclePedIsTryingToEnter(ped)) then
                    table.insert(vehicles, {
                        GetVehiclePedIsTryingToEnter(ped),
                        IsVehicleEngineOn(GetVehiclePedIsTryingToEnter(ped)),
                        (IsVehicleEngineOn(GetVehiclePedIsIn(ped, false)) or HasKeys(GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false)))),
                        true,
                    })
                elseif IsPedInAnyVehicle(ped, false) and not table.contains(vehicles, GetVehiclePedIsIn(ped, false)) then
                    table.insert(vehicles, {
                        GetVehiclePedIsIn(ped, false),
                        IsVehicleEngineOn(GetVehiclePedIsIn(ped, false)),
                        (IsVehicleEngineOn(GetVehiclePedIsIn(ped, false)) or HasKeys(GetVehicleNumberPlateText(GetVehiclePedIsIn(ped, false)))),
                        true,
                    })
                end

                if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) and IsControlPressed(2, 75) and not IsEntityDead(ped) and not IsPauseMenuActive() then
                    Citizen.Wait(150)
                    if DoesEntityExist(ped) and IsPedInAnyVehicle(ped, false) and IsControlPressed(2, 75) and not IsEntityDead(ped) and not IsPauseMenuActive() then
                        local veh = GetVehiclePedIsIn(ped, false)
                        TaskLeaveVehicle(ped, veh, 256)
                    end
                end

                for i, vehicle in ipairs(vehicles) do
                    if DoesEntityExist(vehicle[1]) then
                        if (GetPedInVehicleSeat(vehicle[1], -1) == ped) or IsVehicleSeatFree(vehicle[1], -1) then
                            SetVehicleEngineOn(vehicle[1], vehicle[2], false, false)
                            SetVehicleJetEngineOn(vehicle[1], vehicle[2])
                            if not IsPedInAnyVehicle(ped, false) or (IsPedInAnyVehicle(ped, false) and vehicle[1]~= GetVehiclePedIsIn(ped, false)) then
                                if IsThisModelAHeli(GetEntityModel(vehicle[1])) or IsThisModelAPlane(GetEntityModel(vehicle[1])) then
                                    if vehicle[2] then
                                        SetHeliBladesFullSpeed(vehicle[1])
                                    end
                                end
                            end

                            if IsPedInAnyVehicle(ped) and canAttemptHotwire and canSearchForKey then
                                if GetVehiclePedIsIn(ped) == vehicle[1] then
                                    canHotwire = false
                                    local offCoords =  GetOffsetFromEntityInWorldCoords(vehicle[1], 0.0, 2.0, 1.0)
                                    if not vehicle[2] and not vehicle[3] then
                                        canHotwire = true
                                        if canAttemptHotwire and canSearchForKey then
                                            --exports['mythic_base']:PrintHelpText('~INPUT_MULTIPLAYER_INFO~ Attempt Hot Wire ~c~| ~INPUT_THROW_GRENADE~ ~s~Search For Key')
                                            Print3DText(offCoords, '~c~[Z] ~s~Attempt Hot Wire ~c~| ~c~[G] ~s~Search For Key')
                                        elseif canAttemptHotwire and not canSearchForKey then
                                            --exports['mythic_base']:PrintHelpText('~INPUT_MULTIPLAYER_INFO~ Attempt Hot Wire')
                                            Print3DText(offCoords, '~c~[Z] ~s~Attempt Hot Wire')
                                        elseif canSearchForKey and not canAttemptHotwire then
                                            --exports['mythic_base']:PrintHelpText('~INPUT_THROW_GRENADE~ Search For Key')
                                            Print3DText(offCoords, '~c~[G] ~s~Search For Key')
                                        end
                                    elseif not vehicle[2] and vehicle[3] and vehicle[4] then
                                        --exports['mythic_base']:PrintHelpText('~INPUT_DROP_WEAPON~ Turn On Engine')
                                        Print3DText(offCoords, '~c~[F9] ~s~Turn On Engine')
                                    elseif not vehicle[4] then
                                        --exports['mythic_base']:PrintHelpText('Vehicle Out Of Fuel')
                                        Print3DText(offCoords, 'Vehicle Out Of Fuel')
                                    end
                                end
                            end
                        end
                    else
                        table.remove(vehicles, i)
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent('mythic_engine:client:ForceHotWired')
AddEventHandler('mythic_engine:client:ForceHotWired', function()
    if IsPedInAnyVehicle(PlayerPedId()) then
        Hotwire(GetVehiclePedIsIn(PlayerPedId()))
    else
        exports['mythic_notify']:SendAlert('error', 'Not In Vehicle')
    end
end)

function AttemptHotwire(veh, success, stages, alarm)
    local baseTimer = Config.LockpickTimers[GetVehicleClass(veh)]
    if baseTimer ~= nil then
        local totalTime = baseTimer * stages

        local alarmRoll = math.random(100)
        if alarmRoll <= alarm then
            SetVehicleAlarm(veh, true)
            SetVehicleAlarmTimeLeft(veh, totalTime)
            StartVehicleAlarm(veh)
        end
    
        local wasCancelled = false
        for i = 1, stages, 1 do
            if wasCancelled then
                isAttemptingHotwire = false
                canAttemptHotwire = true
                exports['mythic_notify']:SendAlert('error', 'Hot Wiring Cancelled')
                return
            end
        
            exports['mythic_progbar']:Progress({
                name = "lockpick_action",
                duration = (baseTimer * i),
                label = "Hot Wiring - Stage 1",
                useWhileDead = false,
                canCancel = true,
                controlDisables = {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                },
                animation = {
                    animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                    anim = "machinic_loop_mechandplayer",
                    flags = 49,
                },
            }, function(status)
                wasCancelled = status
            end)
        end
        
        if not wasCancelled then
            local successRoll = math.random(100)
            if successRoll <= success then
                Hotwire(veh)
                exports['mythic_notify']:SendAlert('success', 'Vehicle Hot Wired')
            else
                exports['mythic_notify']:SendAlert('error', 'Hot Wiring Failed')
            end
        end
    else
        exports['mythic_notify']:SendAlert('error', 'Cannot Hotwire This Vehicle')
    end
    
end

function SearchForKey(veh, success, alarm)
    local alarmRoll = math.random(100)
    if alarmRoll <= alarm then
        SetVehicleAlarm(veh, true)
        StartVehicleAlarm(veh)
    end

    exports['mythic_progbar']:Progress({
        name = "lockpick_action",
        duration = 25000,
        label = "Searching Front Seat",
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "amb@medic@standing@tendtodead@base",
            anim = "base",
            flags = 49,
        },
    }, function(status)
        if not status then
            local firstChance = math.random(100)
            if firstChance > 20 then
                isSearching = false
                Hotwire(veh)
                exports['mythic_notify']:SendAlert('success', 'You found a key')
            else
                exports['mythic_progbar']:Progress({
                    name = "lockpick_action",
                    duration = 35000,
                    label = "Searching Back Seat",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    },
                    animation = {
                        animDict = "amb@medic@standing@tendtodead@base",
                        anim = "base",
                        flags = 49,
                    },
                }, function(status)
                    isSearching = false
                    if not status then
                        local successRoll = math.random(100)
                        if successRoll <= success then
                            Hotwire(veh)
                            exports['mythic_notify']:SendAlert('success', 'You found a key')
                        else
                            exports['mythic_notify']:SendAlert('error', 'You didn\'t find anything')
                        end
                    else
                        canSearchForKey = true
                        exports['mythic_notify']:SendAlert('error', 'Search Cancelled')
                    end
                end)
                isSearching = false
            end
        else
            canSearchForKey = true
            exports['mythic_notify']:SendAlert('error', 'Search Cancelled')
        end
    end)
end

function SetEngineState()
    local veh
	local StateIndex
	for i, vehicle in ipairs(vehicles) do
		if vehicle[1] == GetVehiclePedIsIn(PlayerPedId(), false) then
			veh = vehicle[1]
			StateIndex = i
		end
    end
    
	if IsPedInAnyVehicle(PlayerPedId(), false) then 
        if (GetPedInVehicleSeat(veh, -1) == PlayerPedId()) then
            if vehicles[StateIndex][3] then
                if vehicles[StateIndex][4] then
                    vehicles[StateIndex][2] = not GetIsVehicleEngineRunning(veh)
                    if vehicles[StateIndex][2] then
                        exports['mythic_notify']:SendAlert('inform', 'Engine Turned On', 1000)
                    else
                        exports['mythic_notify']:SendAlert('inform', 'Engine Turned Off', 1000)
                    end
                else
                    exports['mythic_notify']:SendAlert('error', 'Vehicle Is Out Of Fuel')
                end
            else
                exports['mythic_notify']:SendAlert('error', 'Unable to interact with vehicle\'s engine', 5000)
            end
		end 
    end 
        
    Citizen.Wait(600)
    isToggling = false
end

function table.contains(table, element)
  for _, value in pairs(table) do
    if value[1] == element then
      return true
    end
  end
  return false
end

--[[ Exported Functions ]]--
function Hotwire(veh)
    for i, vehicle in ipairs(vehicles) do
        if vehicle[1] == veh then
            canAttemptHotwire = false
            canSearchForKey = false
            vehicle[2] = true
            vehicle[3] = true
        end
    end
end

function SetHotwireState(veh)
    for i, vehicle in ipairs(vehicles) do
        if vehicle[1] == veh then
            vehicle[3] = true
        end
    end
end

function IsCarHotwired(veh)
    for i, vehicle in ipairs(vehicles) do
        if vehicle[1] == veh then
            return vehicle[3]
        end
    end

    return false
end

function OutOfFuel(veh)
    for i, vehicle in ipairs(vehicles) do
        if vehicle[1] == veh then
            vehicle[2] = false
            vehicle[4] = false
        end
    end
end

function Refueled(veh)
    for i, vehicle in ipairs(vehicles) do
        if vehicle[1] == veh then
            vehicle[4] = true
            TriggerEvent('mythic_ui:client:UpdateFuel', veh)
        end
    end
end

function IsVehFueled(veh)
    for i, vehicle in ipairs(vehicles) do
        if vehicle[1] == veh then
            return vehicle[4]
        end
    end
end