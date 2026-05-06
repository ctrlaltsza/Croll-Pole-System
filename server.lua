local poleDancers = {}
local cleanedRolls = {}

local function getFramework()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    elseif GetResourceState('mythic-base') == 'started' or GetResourceState('mythic-framework') == 'started' then
        return 'mythic'
    end

    return Config.Framework or 'standalone'
end

local function getPlayerObject(src)
    local fw = getFramework()

    if fw == 'qbox' then
        return exports.qbx_core:GetPlayer(src), fw
    elseif fw == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayer(src), fw
    elseif fw == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerFromId(src), fw
    end

    return nil, fw
end

local function getIdentifier(src)
    local player, fw = getPlayerObject(src)

    if fw == 'qbox' and player and player.PlayerData then
        return player.PlayerData.citizenid or tostring(src)
    elseif fw == 'qbcore' and player and player.PlayerData then
        return player.PlayerData.citizenid or tostring(src)
    elseif fw == 'esx' and player then
        return player.identifier or tostring(src)
    elseif fw == 'mythic' then
        return tostring(src)
    end

    return tostring(src)
end

local function removeItem(src, item, amount)
    if GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:RemoveItem(src, item, amount)
    end

    local player, fw = getPlayerObject(src)
    if not player then return false end

    if fw == 'qbcore' or fw == 'qbox' then
        return player.Functions.RemoveItem(item, amount)
    elseif fw == 'esx' then
        local invItem = player.getInventoryItem(item)
        if invItem and invItem.count >= amount then
            player.removeInventoryItem(item, amount)
            return true
        end
    end

    return false
end

local function addCleanMoney(src, amount)
    if amount <= 0 then return false end

    if Config.CleanMoneyAsItem and GetResourceState('ox_inventory') == 'started' then
        return exports.ox_inventory:AddItem(src, Config.Items.cleanMoney, amount)
    end

    local player, fw = getPlayerObject(src)
    if not player then return false end

    if fw == 'qbcore' or fw == 'qbox' then
        player.Functions.AddMoney('cash', amount, 'stripper-pole-cleaning')
        return true
    elseif fw == 'esx' then
        player.addMoney(amount)
        return true
    elseif fw == 'mythic' then
        return true
    end

    return false
end

local function notify(src, title, description, nType)
    TriggerClientEvent('ox_lib:notify', src, {
        title = title,
        description = description,
        type = nType
    })
end

local function getRollValue(totalCleaned)
    local progression = Config.RollCleaningProgression
    if totalCleaned <= 1 then
        return progression[1]
    elseif totalCleaned == 2 then
        return progression[2]
    elseif totalCleaned == 3 then
        return progression[3]
    else
        return progression[4]
    end
end

RegisterNetEvent('nc-stripper:server:setDancing', function(poleId, state)
    local src = source

    if state then
        poleDancers[poleId] = src
    elseif poleDancers[poleId] == src then
        poleDancers[poleId] = nil
    end

    TriggerClientEvent('nc-stripper:client:updateDancingState', -1, poleId, src, state)
end)

RegisterNetEvent('nc-stripper:server:throwMoney', function(itemName, poleId)
    local src = source

    if not poleDancers[poleId] then
        notify(src, 'No Dancer', 'There must be someone dancing on the pole first.', 'error')
        return
    end

    local removed = removeItem(src, itemName, 1)
    if not removed then
        notify(src, 'Missing Item', ('You need at least 1x %s.'):format(itemName), 'error')
        return
    end

    notify(src, 'Money Thrown', ('You threw 1x %s at the dancer.'):format(itemName), 'success')
end)

RegisterNetEvent('nc-stripper:server:cleanMoney', function(itemName, poleId)
    local src = source

    if not poleDancers[poleId] then
        notify(src, 'No Dancer', 'There must be someone dancing on the pole first.', 'error')
        return
    end

    local removed = removeItem(src, itemName, 1)
    if not removed then
        notify(src, 'Missing Item', ('You need at least 1x %s.'):format(itemName), 'error')
        return
    end

    local identifier = getIdentifier(src)
    cleanedRolls[identifier] = cleanedRolls[identifier] or 0

    local payout = 0
    if itemName == Config.Items.cashroll then
        local nextCount = cleanedRolls[identifier] + 1
        payout = getRollValue(nextCount)
        cleanedRolls[identifier] = nextCount
    elseif itemName == Config.Items.cashband then
        payout = Config.BandWorth
    end

    local paid = addCleanMoney(src, payout)
    if not paid and getFramework() == 'mythic' then
        notify(src, 'Framework Notice', 'Mythic money reward bridge needs to be linked to your economy resource.', 'inform')
    end

    notify(src, 'Money Cleaned', ('You cleaned 1x %s into $%s clean money.'):format(itemName, payout), 'success')
end)
