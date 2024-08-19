ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)


local npcModel = Config.NPCModel
local npcCoords = Config.NpcCoords 
local npcRadius = Config.NpcRadius

-- Crear el NPC
Citizen.CreateThread(function()
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Citizen.Wait(0)
    end
    local npc = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z, Config.NpcHeading, true, false)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedCanRagdoll(npc, false)
    SetPedDiesWhenInjured(npc, false)
    SetPedHearingRange(npc, 0.0)
    SetPedSeeingRange(npc, 0.0)
    SetPedAlertness(npc, 0.0)
    SetEntityInvincible(npc, true) -- Godmode
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end)


function isPlayerNearNPC()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - npcCoords)
    return distance <= npcRadius
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isPlayerNearNPC() then
            SetTextComponentFormat('STRING')
            AddTextComponentString('Presiona ~INPUT_CONTEXT~ para blanquear dinero negro')
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)

            if IsControlJustReleased(0, 38) then 
                requestOpenMenu()
            end
        end
    end
end)

function requestOpenMenu()
    TriggerServerEvent('requestOpenMenu')
end


RegisterNetEvent('openMenu')
AddEventHandler('openMenu', function()
    local input = lib.inputDialog('Blanqueador de dinero', {'¿Cuánto dinero negro quieres blanquear?'})

    if input and tonumber(input[1]) then
        local amount = tonumber(input[1])
        TriggerServerEvent('blanqueoDeDineroNegro', amount)
    else
        lib.notify({
            title = 'Error',
            description = 'Cantidad inválida o no ingresada.',
            type = 'error'
        })
    end
end)


RegisterNetEvent('showNotification')
AddEventHandler('showNotification', function(message)
    lib.notify({
        title = 'Notificación',
        description = message,
        type = 'error'
    })
end)




RegisterNetEvent('returnBankMoney')
AddEventHandler('returnBankMoney', function(bankMoney)
    print("El jugador tiene $" .. bankMoney .. " en su cuenta bancaria.")
    TriggerEvent('chat:addMessage', {
        args = {"[Servidor]", "Tienes $" .. bankMoney .. " en tu cuenta bancaria."}
    })
end)

RegisterNetEvent('sendCashAmount')
AddEventHandler('sendCashAmount', function(cashAmount)
    lib.notify({
        title = 'Dinero en efectivo',
        description = 'Tienes $' .. cashAmount .. ' en efectivo.',
        type = 'success'
    })
end)

RegisterNetEvent('sendBlackMoneyAmount')
AddEventHandler('sendBlackMoneyAmount', function(blackMoneyAmount)
    lib.notify({
        title = 'Dinero Negro',
        description = 'Tienes $' .. blackMoneyAmount .. ' en dinero negro.',
        type = 'success'
    })
end)

RegisterNetEvent('notifyBlanqueoSuccess')
AddEventHandler('notifyBlanqueoSuccess', function(amount)
    lib.notify({
        title = 'Blanqueo Exitoso',
        description = 'Has blanqueado $' .. amount .. ' y lo has recibido en efectivo.',
        type = 'success'
    })
end)

RegisterNetEvent('notifyBlanqueoFailure')
AddEventHandler('notifyBlanqueoFailure', function()
    lib.notify({
        title = 'Blanqueo Fallido',
        description = 'No tienes suficiente dinero negro para blanquear.',
        type = 'error'
    })
end)
RegisterNetEvent('traersteamalcliente')
AddEventHandler('traersteamalcliente', function()
    TriggerServerEvent('enviarsteam')
end)