-----------------------------------[   VARIABLEN   ]-----------------------------------
local activeNPCs      = {}

-----------------------------------[   FUNKTIONEN   ]-----------------------------------
local Notify = function(message, color, flash, saveToBrief)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    ThefeedSetNextPostBackgroundColor(color)
    EndTextCommandThefeedPostTicker(false, saveToBrief)
end

local spawnNPC = function(vehicle)
    local seats       = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    local maxNPCs     = math.random(1, seats - 1) -- Random Anzahl an NPCs in dein Auto setzen
    local spawnedNPCs = 0

    for seat = -1, seats - 2 do
        if IsVehicleSeatFree(vehicle, seat) then
            local npcModel = Config.NPCModels[math.random(#Config.NPCModels)]
            RequestModel(npcModel)
            while not HasModelLoaded(npcModel) do
                Wait(0)
            end
            local ped = CreatePedInsideVehicle(vehicle, 4, npcModel, seat, true, false)
            SetModelAsNoLongerNeeded(npcModel)
            table.insert(activeNPCs, {npc = ped, vehicle = vehicle})
            spawnedNPCs     = spawnedNPCs + 1

            if spawnedNPCs >= maxNPCs then
                break
            end
        end
    end
    Notify(maxNPCs.. " NPC wurden ins Fahrzeug gesetzt.", 140, true, true)
        
end

local despawnNPCs = function(force)
    for i = #activeNPCs, 1, -1 do
        local npcData = activeNPCs[i]
        local npc = npcData.npc
        local vehicle = npcData.vehicle

        if force or not DoesEntityExist(vehicle) or not IsPedInVehicle(npc, vehicle, false) then
            if DoesEntityExist(npc) then
                DeleteEntity(npc)
            end
            table.remove(activeNPCs, i)
        end
    end
end

-----------------------------------[   COMMANDS   ]-----------------------------------

RegisterCommand("spawnnpc", function()
    local playerPed = PlayerPedId()
    local vehicle   = GetVehiclePedIsIn(playerPed, false)

    if vehicle     ~= 0 then
        spawnNPC(vehicle)
    else
        Notify("~r~Du bist in keinem Fahrzeug!", 140, true, true)
    end

end, false)

RegisterCommand("removenpc", function()
    despawnNPCs(true)
    Notify("~r~Alle NPC wurden entfernt!", 140, true, true)
end, false)

-----------------------------------[   THREADS   ]-----------------------------------
CreateThread(function()
    while true do
        Wait(5000)
        despawnNPCs(false)
    end
end)