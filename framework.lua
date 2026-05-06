Framework = {}

local detectedFramework = nil

local function resourceStarted(name)
    return GetResourceState(name) == 'started'
end

function Framework.GetName()
    if detectedFramework then return detectedFramework end

    if resourceStarted('qbx_core') then
        detectedFramework = 'qbox'
    elseif resourceStarted('qb-core') then
        detectedFramework = 'qbcore'
    elseif resourceStarted('es_extended') then
        detectedFramework = 'esx'
    elseif resourceStarted('mythic-base') or resourceStarted('mythic-framework') then
        detectedFramework = 'mythic'
    else
        detectedFramework = Config.Framework or 'standalone'
    end

    return detectedFramework
end

function Framework.GetPlayerData()
    local name = Framework.GetName()

    if name == 'qbox' then
        return exports.qbx_core:GetPlayerData()
    elseif name == 'qbcore' then
        local QBCore = exports['qb-core']:GetCoreObject()
        return QBCore.Functions.GetPlayerData()
    elseif name == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        return ESX.GetPlayerData()
    end

    return nil
end

function Framework.HasJob(jobList)
    if not Config.JobLock.enabled then return true end

    local playerData = Framework.GetPlayerData()
    local jobName = nil

    if playerData then
        if playerData.job and playerData.job.name then
            jobName = playerData.job.name
        elseif playerData.job and playerData.job.id then
            jobName = playerData.job.id
        end
    end

    if not jobName and Framework.GetName() == 'mythic' then
        return true
    end

    if not jobName then return false end

    for _, job in pairs(jobList) do
        if jobName == job then
            return true
        end
    end

    return false
end
