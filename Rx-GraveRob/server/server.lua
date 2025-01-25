ESX = exports["es_extended"]:getSharedObject()

local function Legit(playerId, message)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    local playerName = xPlayer and xPlayer.getName() or "Unknown"
    local discordMessage = {
        embeds = {
            {
                title = "Triggeraus yritys",
                description = message,
                color = 1085231,
                fields = {
                    { name = "Player ID", value = playerName, inline = true },
                    { name = "Character Name ", value = tostring(playerId), inline = true }
                }
            }
        }
    }

    PerformHttpRequest(Config.WebhookURL, function() end, "POST", json.encode(discordMessage), { ["Content-Type"] = "application/json" })
end

local function GetOnlinePoliceCount()
    local count = 0
    for _, playerId in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer and xPlayer.job.name == 'police' then
            count = count + 1
        end
    end
    return count
end
local function GetRandomItem()
    local totalChance = 0
    for _, v in ipairs(Config.ItemPool) do
        totalChance = totalChance + v.chance
    end
    local randomChance = math.random(1, totalChance)
    local cumulativeChance = 0
    for _, v in ipairs(Config.ItemPool) do
        cumulativeChance = cumulativeChance + v.chance
        if randomChance <= cumulativeChance then
            local itemCount = math.random(v.minCount, v.maxCount)
            return v.item, itemCount
        end
    end
    return nil, 0
end
RegisterNetEvent('rxjg.grave:checkRequirements', function(location)
    local src = source
    local policeCount = GetOnlinePoliceCount()

    if policeCount >= Config.RequiredPolice then
        TriggerClientEvent('rxjg.grave:canDig', src, true, location)
    else
        TriggerClientEvent('rxjg.grave:canDig', src, false, location)
    end
end)
RegisterNetEvent('rxjg.grave:attemptDig', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local isNearGrave = false
    for _, grave in ipairs(Config.GraveLocations) do
        if #(playerCoords - grave) < 5.5 then
            isNearGrave = true
            break
        end
    end
    if not isNearGrave then
        Legit(src, "Tried to trigger Gravedigging event")
        DropPlayer(src, ":D You cant trigger this.")
        return
    end
    local item, count = GetRandomItem()
    if item and count > 0 then
        exports.ox_inventory:AddItem(src, item, count)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Grave Digging',
            description = ('You Found %d x %s!'):format(count, item),
            type = 'success'
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Grave Digging',
            description = 'You didnt found anything...',
            type = 'error'
        })
    end
end)


