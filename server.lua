ESX = nil

local rESX, rObj = pcall(function()
    ESX = exports['es_extended']:getSharedObject()
end)

if (not rESX) then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

local webhookURL = 'TU WEBHOOK DE DISCORD'

function sendToDiscord(message)
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        content = message
    }), { ['Content-Type'] = 'application/json' })
end


RegisterNetEvent(('%s:getBankMoney'):format(GetCurrentResourceName()), function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local bankMoney = xPlayer.getAccount('bank').money
    TriggerClientEvent(('%s:returnBankMoney'):format(GetCurrentResourceName()), source, bankMoney)
end)

RegisterNetEvent(('%s:blanqueoDeDineroNegro'):format(GetCurrentResourceName()), function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackMoney = xPlayer.getAccount('black_money').money

    if blackMoney >= amount then
        xPlayer.removeAccountMoney('black_money', amount)
        xPlayer.addMoney(amount)

   
        TriggerClientEvent(('%s:notifyBlanqueoSuccess'):format(GetCurrentResourceName()), source, amount)

      
        local playerName = GetPlayerName(source)
        local message = string.format("**Blanqueo de Dinero**\n**Jugador:** %s\n**Cantidad Blanqueada:** $%d\n", playerName, amount)
        sendToDiscord(message)
    else
      
        TriggerClientEvent(('%s:notifyBlanqueoFailure'):format(GetCurrentResourceName()), source)
    end
end)

RegisterNetEvent(('%s:withdrawAllBankMoney'):format(GetCurrentResourceName()), function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local bankMoney = xPlayer.getAccount('bank').money
    
    xPlayer.removeAccountMoney('bank', bankMoney)
    xPlayer.addMoney(bankMoney)
    
    TriggerClientEvent(('%s:returnBankMoney'):format(GetCurrentResourceName()), source, 0)
end)


function hasJob(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if xPlayer and xPlayer.job then
        for _, job in ipairs(Config.RequiredJobs) do
            if xPlayer.job.name == job then
                return true
            end
        end
    end
    return false
end


RegisterServerEvent(('%s:requestOpenMenu'):format(GetCurrentResourceName()), function()
    local playerId = source
    if hasJob(playerId) then
        TriggerClientEvent(('%s:openMenu'):format(GetCurrentResourceName()), playerId)
    else
        TriggerClientEvent(('%s:showNotification'):format(GetCurrentResourceName()), playerId, "No tienes el trabajo requerido, no se puede abrir el menú de blanqueo.")
    end
end)
