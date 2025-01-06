Config = {}

-- Maximum XP a player can earn
Config.MaxXP = 10000

-- Levels and their XP requirements
Config.Levels = {
    [1] = 100,   -- XP required for level 1
    [2] = 300,   -- XP required for level 2
    [3] = 600,   -- XP required for level 3
    [4] = 1000,  -- XP required for level 4
    -- Add more levels as needed
}

-- Rewards for levels
Config.Rewards = {
    [2] = {money = 500, items = { {name = 'water', amount = 2} }},
    [3] = {money = 1000, items = { {name = 'bread', amount = 5} }},
    [4] = {money = 2000, items = { {name = 'weapon_pistol', amount = 1} }},
    -- Add more rewards as needed
}

-- Update interval for client-server synchronization (in milliseconds)
Config.UpdateInterval = 1000
