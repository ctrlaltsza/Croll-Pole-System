local poleDancers = {}
local cleanedRolls = {}

local function getIdentifier(src)
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return tostring(src) end
    return player.PlayerData.citizenid or tostring(src)
end

local function getRollValue(totalCleaned)
    local progression = Config.RollCleaningProgression
    if totalCleaned <= 0 then
        return progression[1]
    elseif totalCleaned == 1 then
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
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    if not poleDancers[poleId] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'No Dancer',
            description = 'There must be someone dancing on the pole first.',
            type = 'error'
        })
        return
    end

    local removed = exports.ox_inventory:RemoveItem(src, itemName, 1)
    if not removed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Missing Item',
            description = ('You need at least 1x %s.'):format(itemName),
            type = 'error'
        })
        return
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Money Thrown',
        description = ('You threw 1x %s at the dancer.'):format(itemName),
        type = 'success'
    })
end)

RegisterNetEvent('nc-stripper:server:cleanMoney', function(itemName, poleId)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    if not player then return end

    if not poleDancers[poleId] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'No Dancer',
            description = 'There must be someone dancing on the pole first.',
            type = 'error'
        })
        return
    end

    local removed = exports.ox_inventory:RemoveItem(src, itemName, 1)
    if not removed then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Missing Item',
            description = ('You need at least 1x %s.'):format(itemName),
            type = 'error'
        })
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

    if payout > 0 then
        exports.ox_inventory:AddItem(src, Config.Items.cleanMoney, payout)
    end

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Money Cleaned',
        description = ('You cleaned 1x %s into $%s clean money.'):format(itemName, payout),
        type = 'success'
    })
end)
