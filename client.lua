ESX = exports['es_extended']:getSharedObject()

local hunger, thirst, alcohol = 100, 100, 0
local notifiedLowHunger = false
local notifiedLowThirst = false
local hudVisible = true
local isDrunk = false
local drunkCheckThread = nil

-- Commande /hud pour activer/désactiver l'affichage
RegisterCommand("hud", function()
    hudVisible = not hudVisible

    if hudVisible then
        SendNUIMessage({ action = "showAll" })
        
        ESX.ShowNotification("HUD :  ~g~activé")
    else
        SendNUIMessage({ action = "hideAll" })
       
        ESX.ShowNotification("HUD :  ~r~désactivé")
    end
end)


-- Mise à jour visuelle automatique
CreateThread(function()
    while true do
        Wait(3000)
        if hudVisible then
            SendNUIMessage({
                action = 'updateStatus',
                hunger = hunger,
                thirst = thirst,
                alcohol = alcohol
            })

            if alcohol > 0 then
                SendNUIMessage({ action = 'showAlcohol' })
            else
                SendNUIMessage({ action = 'hideAlcohol' })
            end

            if hunger <= 15 and not notifiedLowHunger then
                notifiedLowHunger = true
                TriggerEvent('esx:showNotification', '~o~Vous avez faim !')
                SendNUIMessage({ action = 'warnHunger' })
            elseif hunger > 15 and notifiedLowHunger then
                notifiedLowHunger = false
                SendNUIMessage({ action = 'clearHunger' })
            end

            if thirst <= 15 and not notifiedLowThirst then
                notifiedLowThirst = true
                TriggerEvent('esx:showNotification', '~b~Vous avez soif !')
                SendNUIMessage({ action = 'warnThirst' })
            elseif thirst > 15 and notifiedLowThirst then
                notifiedLowThirst = false
                SendNUIMessage({ action = 'clearThirst' })
            end
        end
    end
end)

-- Mise à jour des valeurs depuis le serveur
RegisterNetEvent('hud:updateStatus', function(_hunger, _thirst, _alcohol)
    hunger = math.min(_hunger, 100)
    thirst = math.min(_thirst, 100)
    alcohol = math.max(0, math.min(_alcohol or 0, 100))

    if hudVisible then
        SendNUIMessage({
            action = 'updateStatus',
            hunger = hunger,
            thirst = thirst,
            alcohol = alcohol
        })

        if alcohol > 0 then
            SendNUIMessage({ action = 'showAlcohol' })
        else
            SendNUIMessage({ action = 'hideAlcohol' })
        end
    end
end)

RegisterNetEvent('hud:addThirst', function(amount)
    thirst = math.min(thirst + amount, 100)
    TriggerServerEvent('hud:saveStatus', hunger, thirst, alcohol)
    if hudVisible then
        SendNUIMessage({ action = 'updateStatus', hunger = hunger, thirst = thirst, alcohol = alcohol })
    end
end)

RegisterNetEvent('hud:addHunger', function(amount)
    hunger = math.min(hunger + amount, 100)
    TriggerServerEvent('hud:saveStatus', hunger, thirst, alcohol)
    if hudVisible then
        SendNUIMessage({ action = 'updateStatus', hunger = hunger, thirst = thirst, alcohol = alcohol })
    end
end)

RegisterNetEvent('hud:addAlcohol', function(amount)
    alcohol = math.min(alcohol + amount, 100)
    TriggerServerEvent('hud:saveStatus', hunger, thirst, alcohol)
    if hudVisible then
        SendNUIMessage({ action = 'updateStatus', hunger = hunger, thirst = thirst, alcohol = alcohol })
        SendNUIMessage({ action = 'showAlcohol' })
    end
end)

RegisterNetEvent('hud:takeDamage', function(amount)
    ApplyDamageToPed(PlayerPedId(), amount)
end)

AddEventHandler('esx:playerLoaded', function()
    TriggerServerEvent('hud:requestStatus')
end)

-- Effets d’ivresse si alcool ≥ 30
CreateThread(function()
    while true do
        Wait(5000)
        if alcohol >= 30 and not isDrunk then
            isDrunk = true
            StartDrunkEffect()
        elseif alcohol < 30 and isDrunk then
            isDrunk = false
            StopDrunkEffect()
        end
    end
end)

function StartDrunkEffect()
    RequestAnimSet("move_m@drunk@verydrunk")
    while not HasAnimSetLoaded("move_m@drunk@verydrunk") do Wait(100) end

    SetPedMovementClipset(PlayerPedId(), "move_m@drunk@verydrunk", true)
    SetTimecycleModifier("spectator5")
    ShakeGameplayCam("DRUNK_SHAKE", 1.0)

    drunkCheckThread = CreateThread(function()
        while isDrunk do
            if alcohol >= 80 and math.random(1, 100) <= 25 then
                local ped = PlayerPedId()
                if not IsPedRagdoll(ped) then
                    SetPedToRagdoll(ped, 3000, 3000, 0, false, false, false)
                    TriggerEvent('esx:showNotification', "~r~Vous perdez l'équilibre...")
                end
            end
            Wait(10000)
        end
    end)
end

function StopDrunkEffect()
    ResetPedMovementClipset(PlayerPedId(), 0.0)
    ClearTimecycleModifier()
    StopGameplayCamShaking(true)

    if drunkCheckThread then
        TerminateThread(drunkCheckThread)
        drunkCheckThread = nil
    end
end
