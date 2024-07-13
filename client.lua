local QBCore = exports['qb-core']:GetCoreObject()
local tracking = false
local targetCoords = nil
local blip = nil

RegisterNetEvent('playertrack:trackPlayer')
AddEventHandler('playertrack:trackPlayer', function(targetId)
    tracking = true

end)

RegisterNetEvent('playertrack:stopTracking')
AddEventHandler('playertrack:stopTracking', function()
    tracking = false
    targetCoords = nil
    if blip then
        RemoveBlip(blip)
        blip = nil
    end
    ClearGpsPlayerWaypoint()

end)

RegisterNetEvent('playertrack:updateWaypoint')
AddEventHandler('playertrack:updateWaypoint', function(coords)
    if tracking then
        targetCoords = coords
        if not blip then
            blip = AddBlipForCoord(targetCoords.x, targetCoords.y, targetCoords.z)
            SetBlipSprite(blip, 1) -- Set the blip sprite
            SetBlipColour(blip, 3) -- Set the blip color
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Tracked Player")
            EndTextCommandSetBlipName(blip)
        else
            SetBlipCoords(blip, targetCoords.x, targetCoords.y, targetCoords.z)
        end
        SetNewWaypoint(targetCoords.x, targetCoords.y)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if tracking and targetCoords then
            SetNewWaypoint(targetCoords.x, targetCoords.y)
        end
    end
end)