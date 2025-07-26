ESX = exports['es_extended']:getSharedObject()
local Config = Config or {}

-- Envoie les données de status au client 
RegisterServerEvent('hud:requestStatus')
AddEventHandler('hud:requestStatus', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    MySQL.query('SELECT status FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
        if result[1] and result[1].status then
            local data = json.decode(result[1].status)
            local hunger = data.hunger or 100
            local thirst = data.thirst or 100
            local alcohol = data.alcohol or 0
            TriggerClientEvent('hud:updateStatus', src, hunger, thirst, alcohol)
        else
            local defaultStatus = json.encode({ hunger = 100, thirst = 100, alcohol = 0 })
            MySQL.update('UPDATE users SET status = ? WHERE identifier = ?', {defaultStatus, xPlayer.identifier})
            TriggerClientEvent('hud:updateStatus', src, 100, 100, 0)
        end
    end)
end)

-- Enregistrement des nouvelles valeurs
RegisterServerEvent('hud:saveStatus')
AddEventHandler('hud:saveStatus', function(hunger, thirst, alcohol)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local status = json.encode({ hunger = hunger, thirst = thirst, alcohol = alcohol or 0 })
    MySQL.update('UPDATE users SET status = ? WHERE identifier = ?', {status, xPlayer.identifier})
end)

-- Diminution automatique de faim/soif/alcool selon intervalle de config
CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        local players = ESX.GetPlayers()

        for _, playerId in pairs(players) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                MySQL.query('SELECT status FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
                    if result[1] and result[1].status then
                        local data = json.decode(result[1].status)

                        local hunger = (data.hunger or 100) - Config.HungerLoss
                        local thirst = (data.thirst or 100) - Config.ThirstLoss
                        local alcohol = (data.alcohol or 0) - (Config.AlcoholLoss or 0)

                        hunger = math.max(hunger, 0)
                        thirst = math.max(thirst, 0)
                        alcohol = math.max(alcohol, 0)

                        local status = json.encode({ hunger = hunger, thirst = thirst, alcohol = alcohol })
                        MySQL.update('UPDATE users SET status = ? WHERE identifier = ?', {status, xPlayer.identifier})

                        TriggerClientEvent('hud:updateStatus', playerId, hunger, thirst, alcohol)

                        if hunger <= 0 or thirst <= 0 then
                            TriggerClientEvent('hud:takeDamage', playerId, 10)
                        end
                    end
                end)
            end
        end
    end
end)

------------------------------------------------
-- 🔥 Perte de vie continue si faim < 1 ou soif < 1
CreateThread(function()
    while true do
        Wait(2000) -- Toutes les 2 secondes

        for _, playerId in pairs(ESX.GetPlayers()) do
            local xPlayer = ESX.GetPlayerFromId(playerId)
            if xPlayer then
                MySQL.query('SELECT status FROM users WHERE identifier = ?', {xPlayer.identifier}, function(result)
                    if result[1] and result[1].status then
                        local data = json.decode(result[1].status)
                        local hunger = tonumber(data.hunger) or 100
                        local thirst = tonumber(data.thirst) or 100

                        if hunger < 1 or thirst < 1 then
                            TriggerClientEvent('hud:takeDamage', playerId, 5)
                        end
                    end
                end)
            end
        end
    end
end)

----------------------------------------------------------------

-- Commande /heal uniquement pour les admins
RegisterCommand('heal', function(source, args)
    local src = source
    local xAdmin = ESX.GetPlayerFromId(src)

    if xAdmin and xAdmin.getGroup() == 'admin' then
        local targetId = tonumber(args[1])
        if targetId then
            local xTarget = ESX.GetPlayerFromId(targetId)
            if xTarget then
                local status = json.encode({ hunger = 100, thirst = 100, alcohol = 0 })
                MySQL.update('UPDATE users SET status = ? WHERE identifier = ?', {status, xTarget.identifier})
                TriggerClientEvent('hud:updateStatus', targetId, 100, 100, 0)
                TriggerClientEvent('esx:showNotification', targetId, '~g~Votre faim et votre soif ont été restaurées.')
                TriggerClientEvent('esx:showNotification', src, '~g~Vous avez soigné le joueur ID ~b~' .. targetId .. '~s~.')
            else
                TriggerClientEvent('esx:showNotification', src, '~r~Joueur introuvable.')
            end
        else
            TriggerClientEvent('esx:showNotification', src, '~r~Usage : /heal [ID]')
        end
    else
        TriggerClientEvent('esx:showNotification', src, '~r~Vous n’êtes pas autorisé à utiliser cette commande.')
    end
end, false)

-- 🔹 ITEM : WATER
ESX.RegisterUsableItem('water', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    xPlayer.removeInventoryItem('water', 1)
    TriggerClientEvent('hud:addThirst', source, 15)
    TriggerClientEvent('esx:showNotification', source, 'Tu as bu de ~b~l\'eau~s~.')
end)

-- 🔸 ITEM : BREAD
ESX.RegisterUsableItem('bread', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    xPlayer.removeInventoryItem('bread', 1)
    TriggerClientEvent('hud:addHunger', source, 15)
    TriggerClientEvent('esx:showNotification', source, 'Tu as mangé du ~o~pain~s~.')
end)

-- 🥃 ITEM : VODKA
ESX.RegisterUsableItem('vodka', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    xPlayer.removeInventoryItem('vodka', 1)
    TriggerClientEvent('hud:addAlcohol', source, 25)
    TriggerClientEvent('esx:showNotification', source, 'Tu as bu de la ~p~vodka~s~.')
end)