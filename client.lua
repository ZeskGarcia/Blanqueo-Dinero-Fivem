ESX = nil

local rESX, rObject = pcall(function()
    ESX = exports['es_extended']:getSharedObject()
end)

if (not rESX and ESX == nil) then
    CreateThread(function()
        while (ESX == nil) do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(250)
        end
    end)
end

local npcModel = Config.NPCModel
local npcCoords = Config.NpcCoords 
local npcRadius = Config.NpcRadius

-- Crear el NPC

function createNPC(model, coords, heading)
    RequestModel(model)
    while (not HasModelLoaded(model)) do
        Wait(250)
    end
    local npc = CreatePed(4, model, coords.x, coords.y, coords.z, heading, true, false)
    SetEntityAsMissionEntity(npc, true, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetPedCanRagdoll(npc, false)
    SetPedDiesWhenInjured(npc, false)
    SetPedHearingRange(npc, 0.0)
    SetPedSeeingRange(npc, 0.0)
    SetPedAlertness(npc, 0.0)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end

Citizen.CreateThread(function()
    createNPC(npcModel, npcCoords, Config.NpcHeading)
end)


function isPlayerNearNPC()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local distance = #(playerCoords - npcCoords)
    return distance <= npcRadius
end

function ShowHelpNotification(text)
    SetTextComponentFormat('STRING')
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

CreateThread(function()
    local _sleep = true
    while (true) do
        Wait(_sleep and 750 or 0)
        _sleep = not isPlayerNearNPC()
        if ((not _sleep)) then
            ShowHelpNotification('Presiona ~INPUT_CONTEXT~ para blanquear dinero negro')

            if (IsControlJustReleased(0, 38)) then 
                -- TriggerServerEvent('requestOpenMenu')
                TriggerServerEvent(("%s:requestOpenMenu"):format(GetCurrentResourceName()))
            end
        end
    end
end)

RegisterNetEvent(("%s:openMenu"):format(GetCurrentResourceName()), function()
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


RegisterNetEvent(('%s:showNotification'):format(GetCurrentResourceName()) function(message)
    lib.notify({
        title = 'Notificación',
        description = message,
        type = 'error'
    })
end)




RegisterNetEvent(('%s:returnBankMoney'):format(GetCurrentResourceName()), function(bankMoney)
    print("El jugador tiene $" .. bankMoney .. " en su cuenta bancaria.")
    TriggerEvent('chat:addMessage', {
        args = {"[Servidor]", "Tienes $" .. bankMoney .. " en tu cuenta bancaria."}
    })
end)

RegisterNetEvent(('%s:sendCashAmount'):format(GetCurrentResourceName()), function(cashAmount)
    lib.notify({
        title = 'Dinero en efectivo',
        description = 'Tienes $' .. cashAmount .. ' en efectivo.',
        type = 'success'
    })
end)

RegisterNetEvent(('%s:sendBlackMoneyAmount'):format(GetCurrentResourceName()), function(blackMoneyAmount)
    lib.notify({
        title = 'Dinero Negro',
        description = 'Tienes $' .. blackMoneyAmount .. ' en dinero negro.',
        type = 'success'
    })
end)

RegisterNetEvent(('%s:notifyBlanqueoSuccess'):format(GetCurrentResourceName()), function(amount)
    lib.notify({
        title = 'Blanqueo Exitoso',
        description = 'Has blanqueado $' .. amount .. ' y lo has recibido en efectivo.',
        type = 'success'
    })
end)

RegisterNetEvent(('%s:notifyBlanqueoFailure'):format(GetCurrentResourceName()), function()
    lib.notify({
        title = 'Blanqueo Fallido',
        description = 'No tienes suficiente dinero negro para blanquear.',
        type = 'error'
    })
end)
RegisterNetEvent(('%s:traersteamalcliente'):format(GetCurrentResourceName()), function()
    TriggerServerEvent('enviarsteam')
end)
