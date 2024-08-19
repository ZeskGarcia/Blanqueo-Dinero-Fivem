ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local webhookURL = 'TU WEBHOOK DE DISCORD'

function sendToDiscord(message)
    PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
        content = message
    }), { ['Content-Type'] = 'application/json' })
end


RegisterNetEvent('getBankMoney')
AddEventHandler('getBankMoney', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local bankMoney = xPlayer.getAccount('bank').money
    TriggerClientEvent('returnBankMoney', source, bankMoney)
end)

RegisterNetEvent('blanqueoDeDineroNegro')
AddEventHandler('blanqueoDeDineroNegro', function(amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local blackMoney = xPlayer.getAccount('black_money').money

    if blackMoney >= amount then
        xPlayer.removeAccountMoney('black_money', amount)
        xPlayer.addMoney(amount)

   
        TriggerClientEvent('notifyBlanqueoSuccess', source, amount)

      
        local playerName = GetPlayerName(source)
        local message = string.format("**Blanqueo de Dinero**\n**Jugador:** %s\n**Cantidad Blanqueada:** $%d\n", playerName, amount)
        sendToDiscord(message)
    else
      
        TriggerClientEvent('notifyBlanqueoFailure', source)
    end
end)

RegisterNetEvent('withdrawAllBankMoney')
AddEventHandler('withdrawAllBankMoney', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local bankMoney = xPlayer.getAccount('bank').money
    
    xPlayer.removeAccountMoney('bank', bankMoney)
    xPlayer.addMoney(bankMoney)
    
    TriggerClientEvent('returnBankMoney', source, 0)
end)


-- Configuración
Config = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
Config = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
assert(load(Config))()


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


RegisterServerEvent('requestOpenMenu')
AddEventHandler('requestOpenMenu', function()
    local playerId = source
    if hasJob(playerId) then
        TriggerClientEvent('openMenu', playerId)
    else
        TriggerClientEvent('showNotification', playerId, "No tienes el trabajo requerido, no se puede abrir el menú de blanqueo.")
    end
end)