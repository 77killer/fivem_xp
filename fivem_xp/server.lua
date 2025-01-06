-- Server-side script for XP System

local QBCore = exports['qb-core']:GetCoreObject()

-- Table to store player XP data
local PlayerXP = {}

-- Load player XP and level from the database when they join
AddEventHandler('QBCore:Server:PlayerLoaded', function(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        local citizenId = Player.PlayerData.citizenid
        exports.oxmysql:single('SELECT xp, level FROM player_xp WHERE citizenid = ?', {citizenId}, function(result)
            if result then
                PlayerXP[citizenId] = {
                    xp = result.xp,
                    level = result.level
                }
            else
                PlayerXP[citizenId] = { xp = 0, level = 1 }
                exports.oxmysql:insert('INSERT INTO player_xp (citizenid, xp, level) VALUES (?, ?, ?)', {citizenId, 0, 1})
            end
            -- Sync player XP and level with the client
            TriggerClientEvent('xp:updateXP', playerId, PlayerXP[citizenId].xp, PlayerXP[citizenId].level)
        end)
    end
end)

-- Save player XP and level to the database when they disconnect
AddEventHandler('QBCore:Server:PlayerDropped', function(playerId)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        local citizenId = Player.PlayerData.citizenid
        if PlayerXP[citizenId] then
            exports.oxmysql:update('UPDATE player_xp SET xp = ?, level = ? WHERE citizenid = ?', {PlayerXP[citizenId].xp, PlayerXP[citizenId].level, citizenId})
            PlayerXP[citizenId] = nil
        end
    end
end)

-- Callback to get player XP and level
QBCore.Functions.CreateCallback('xp:getPlayerXP', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        local citizenId = Player.PlayerData.citizenid
        cb(PlayerXP[citizenId] or { xp = 0, level = 1 })
    else
        cb(nil)
    end
end)

-- Function to add XP
function AddXP(playerId, amount)
    local Player = QBCore.Functions.GetPlayer(playerId)
    if Player then
        local citizenId = Player.PlayerData.citizenid
        if not PlayerXP[citizenId] then return end

        local data = PlayerXP[citizenId]
        data.xp = math.min(data.xp + amount, Config.MaxXP)

        -- Check for level-up
        for level, xpRequired in pairs(Config.Levels) do
            if data.xp >= xpRequired and data.level < level then
                data.level = level
                TriggerClientEvent('xp:levelUp', playerId, level)
                GrantReward(citizenId, level) -- Grant rewards for leveling up
            end
        end

        -- Sync XP and level with the client
        TriggerClientEvent('xp:updateXP', playerId, data.xp, data.level)
    end
end

-- Command to add XP (admin use only)
QBCore.Commands.Add('addxp', 'Add XP to a player (Admin Only)', {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'XP Amount'}}, true, function(source, args)
    local targetId = tonumber(args[1])
    local amount = tonumber(args[2])
    AddXP(targetId, amount)
    TriggerClientEvent('QBCore:Notify', source, 'Added ' .. amount .. ' XP to player ' .. targetId, 'success')
end, 'admin')

-- Function to grant rewards
function GrantReward(citizenId, level)
    local Player = QBCore.Functions.GetPlayerByCitizenId(citizenId)
    if not Player then return end

    local reward = Config.Rewards[level]
    if not reward then return end

    local playerId = Player.PlayerData.source

    -- Grant money
    if reward.money then
        Player.Functions.AddMoney('bank', reward.money, 'XP Level Reward')
        TriggerClientEvent('QBCore:Notify', playerId, 'You received $' .. reward.money .. ' as a reward!', 'success')
    end

    -- Grant items using ox_inventory
    if reward.items then
        for _, item in ipairs(reward.items) do
            local success = exports.ox_inventory:AddItem(playerId, item.name, item.amount)
            if success then
                TriggerClientEvent('ox_lib:notify', playerId, { type = 'success', description = 'Received ' .. item.amount .. 'x ' .. item.name })
            else
                TriggerClientEvent('ox_lib:notify', playerId, { type = 'error', description = 'Failed to add item: ' .. item.name })
            end
        end
    end
end
