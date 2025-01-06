-- Client-side script for XP System

local QBCore = exports['qb-core']:GetCoreObject()

-- Variables
local playerXP = 0
local playerLevel = 1

-- Function to update XP and Level locally
RegisterNetEvent('xp:updateXP')
AddEventHandler('xp:updateXP', function(xp, level)
    playerXP = xp
    playerLevel = level
    SendNUIMessage({
        action = "updateXP",
        xp = xp,
        level = level
    })
end)

-- Display level-up notification
RegisterNetEvent('xp:levelUp')
AddEventHandler('xp:levelUp', function(level)
    TriggerEvent('chat:addMessage', {
        args = { '^2Congratulations!^7 You have reached level ' .. level .. '!' }
    })
    -- Optionally trigger an animation or sound here
end)

-- Command to show current XP and Level
RegisterCommand('checkxp', function()
    TriggerEvent('chat:addMessage', {
        args = { ('Your current XP: ^2%d^7 | Level: ^2%d^7'):format(playerXP, playerLevel) }
    })
end)

-- Fetch initial XP and Level from the server
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        QBCore.Functions.TriggerCallback('xp:getPlayerXP', function(data)
            if data then
                playerXP = data.xp
                playerLevel = data.level
                SendNUIMessage({
                    action = "updateXP",
                    xp = playerXP,
                    level = playerLevel
                })
            end
        end)
    end
end)
