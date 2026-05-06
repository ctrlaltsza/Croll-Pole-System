local spawnedPoles = {}
local activeDancers = {}
local currentDancePole = nil
local isDancing = false

local function HasJob()
    if not Config.JobLock.enabled then return true end

    local playerData = exports.qbx_core:GetPlayerData()
    if not playerData or not playerData.job then return false end

    for _, job in pairs(Config.JobLock.jobs) do
        if playerData.job.name == job then
            return true
        end
    end

    return false
end

local function LoadAnim(dict)
    lib.requestAnimDict(dict)
end

local function IsPoleOccupied(poleId)
    return activeDancers[poleId] ~= nil
end

local function PlayThrowMoneyAnim()
    local ped = PlayerPedId()
    LoadAnim('anim@mp_player_intcelebrationmale@raining_cash')
    TaskPlayAnim(ped, 'anim@mp_player_intcelebrationmale@raining_cash', 'raining_cash', 8.0, -8.0, 2000, 49, 0.0, false, false, false)
end

local function StartDance(poleId)
    if not HasJob() then
        lib.notify({
            title = 'Access Denied',
            description = 'You are not allowed to use this.',
            type = 'error'
        })
        return
    end

    if IsPoleOccupied(poleId) then
        lib.notify({
            title = 'Pole Busy',
            description = 'Someone is already dancing on this pole.',
            type = 'error'
        })
        return
    end

    local ped = PlayerPedId()
    isDancing = true
    currentDancePole = poleId
    activeDancers[poleId] = GetPlayerServerId(PlayerId())

    FreezeEntityPosition(ped, true)
    LoadAnim(Config.Anim.dict)
    TaskPlayAnim(ped, Config.Anim.dict, Config.Anim.anim, 8.0, -8.0, -1, 1, 0, false, false, false)

    TriggerServerEvent('nc-stripper:server:setDancing', poleId, true)

    lib.notify({
        title = 'Dancing',
        description = 'Press [X] to stop dancing.',
        type = 'inform'
    })

    CreateThread(function()
        while isDancing and currentDancePole == poleId do
            Wait(0)
            if IsControlJustPressed(0, 73) then
                ClearPedTasks(ped)
                FreezeEntityPosition(ped, false)
                isDancing = false
                activeDancers[poleId] = nil
                TriggerServerEvent('nc-stripper:server:setDancing', poleId, false)
                currentDancePole = nil
                break
            end
        end
    end)
end

local function HasNearbyDancer(poleId)
    return activeDancers[poleId] ~= nil
end

local function ThrowMoney(itemName, poleId)
    if not HasNearbyDancer(poleId) then
        lib.notify({
            title = 'No Dancer',
            description = 'There must be someone dancing on the pole first.',
            type = 'error'
        })
        return
    end

    PlayThrowMoneyAnim()
    TriggerServerEvent('nc-stripper:server:throwMoney', itemName, poleId)
end

local function CleanMoney(itemName, poleId)
    if not HasNearbyDancer(poleId) then
        lib.notify({
            title = 'No Dancer',
            description = 'There must be someone dancing on the pole first.',
            type = 'error'
        })
        return
    end

    TriggerServerEvent('nc-stripper:server:cleanMoney', itemName, poleId)
end

local function BuildPoleOptions(poleId)
    return {
        {
            name = 'stripper_pole_dance_' .. poleId,
            icon = 'fas fa-person-dress',
            label = 'Dance',
            canInteract = function()
                return not IsPoleOccupied(poleId)
            end,
            onSelect = function()
                StartDance(poleId)
            end
        },
        {
            name = 'stripper_pole_throw_roll_' .. poleId,
            icon = 'fas fa-money-bill-wave',
            label = 'Throw Cash Roll',
            canInteract = function()
                return HasNearbyDancer(poleId)
            end,
            onSelect = function()
                ThrowMoney(Config.Items.cashroll, poleId)
            end
        },
        {
            name = 'stripper_pole_throw_band_' .. poleId,
            icon = 'fas fa-money-bill-wave',
            label = 'Throw Cash Band',
            canInteract = function()
                return HasNearbyDancer(poleId)
            end,
            onSelect = function()
                ThrowMoney(Config.Items.cashband, poleId)
            end
        },
        {
            name = 'stripper_pole_clean_roll_' .. poleId,
            icon = 'fas fa-hand-holding-dollar',
            label = 'Clean Cash Roll',
            canInteract = function()
                return HasNearbyDancer(poleId)
            end,
            onSelect = function()
                CleanMoney(Config.Items.cashroll, poleId)
            end
        },
        {
            name = 'stripper_pole_clean_band_' .. poleId,
            icon = 'fas fa-sack-dollar',
            label = 'Clean Cash Band',
            canInteract = function()
                return HasNearbyDancer(poleId)
            end,
            onSelect = function()
                CleanMoney(Config.Items.cashband, poleId)
            end
        }
    }
end

local function AddTarget(entity, poleId)
    exports.ox_target:addLocalEntity(entity, BuildPoleOptions(poleId))
end

local function SpawnPoles()
    for i, v in pairs(Config.PropLocations) do
        local model = Config.PropModel
        lib.requestModel(model)

        local obj = CreateObject(model, v.coords.x, v.coords.y, v.coords.z, false, false, false)
        SetEntityHeading(obj, v.heading)
        FreezeEntityPosition(obj, true)

        spawnedPoles[i] = obj
        AddTarget(obj, i)
    end
end

local function AddCoordTargets()
    for i, data in pairs(Config.Poles) do
        exports.ox_target:addSphereZone({
            coords = data.coords,
            radius = data.radius or 1.5,
            debug = false,
            options = BuildPoleOptions(i)
        })
    end
end

RegisterNetEvent('nc-stripper:client:updateDancingState', function(poleId, serverId, state)
    if state then
        activeDancers[poleId] = serverId
    else
        activeDancers[poleId] = nil
    end
end)

CreateThread(function()
    if Config.UseProps then
        SpawnPoles()
    else
        AddCoordTargets()
    end
end)