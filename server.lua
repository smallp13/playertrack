QBCore = exports['qb-core']:GetCoreObject()

local trackedPlayers = {}

RegisterCommand('track', function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if trackedPlayers[source] then
        trackedPlayers[source] = nil
        TriggerClientEvent('playertrack:stopTracking', source)
        TriggerClientEvent('QBCore:Notify', source, "Stopped tracking", "error")
        return
    end

    if Player.PlayerData.job.name == 'police' or Player.PlayerData.job.name == 'ambulance' then
        local targetId = tonumber(args[1])

        if targetId and GetPlayerName(targetId) then
            if source == targetId then
                TriggerClientEvent('QBCore:Notify', source, "You cannot track yourself", "error")
            else
                local TargetPlayer = QBCore.Functions.GetPlayer(targetId)
                if TargetPlayer and (TargetPlayer.PlayerData.job.name == 'police' or TargetPlayer.PlayerData.job.name == 'ambulance') then
                    trackedPlayers[source] = targetId
                    TriggerClientEvent('playertrack:trackPlayer', source, targetId)
                    TriggerClientEvent('QBCore:Notify', source, "Tracking player " .. targetId, "success")
                else
                    TriggerClientEvent('QBCore:Notify', source, "You can only track players with police or ambulance jobs", "error")
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', source, "Player not found", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', source, "You do not have permission to use this command", "error")
    end
end)

AddEventHandler('playerDropped', function()
    local source = source
    if trackedPlayers[source] then
        trackedPlayers[source] = nil
        TriggerClientEvent('playertrack:stopTracking', -1, source)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for tracker, target in pairs(trackedPlayers) do
            if GetPlayerPing(target) > 0 then
                local trackerPed = GetPlayerPed(tracker)
                local targetPed = GetPlayerPed(target)
                local trackerCoords = GetEntityCoords(trackerPed)
                local targetCoords = GetEntityCoords(targetPed)

                -- Calculate distance between tracker and target
                local distance = #(trackerCoords - targetCoords)

                -- Check if tracker has arrived at target's location
                if distance < 10.0 then -- Threshold distance (adjust as needed)
                    trackedPlayers[tracker] = nil
                    TriggerClientEvent('playertrack:stopTracking', tracker)
                    TriggerClientEvent('QBCore:Notify', tracker, "You have arrived at the tracked player's location", "success")
                else
                    TriggerClientEvent('playertrack:updateWaypoint', tracker, targetCoords)
                end
            else
                trackedPlayers[tracker] = nil
                TriggerClientEvent('playertrack:stopTracking', tracker)
                TriggerClientEvent('QBCore:Notify', tracker, "Lost connection to the tracked player", "error")
            end
        end
    end
end)
