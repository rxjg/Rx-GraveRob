local digging = false
local cooldown = false
local blipsEnabled = false

local function hasShovel()
    local count = exports.ox_inventory:Search('count', Config.neededitem.neededItem)
    if count == 0 then
        TriggerEvent('ox_lib:notify', {
            title = 'Haudankaivuu',
            description = 'You need Shovel to start Digging!!',
            type = 'error'
        })
        return false
    end
    return true
end
local function StartDigging(location)
    if digging or cooldown then
        TriggerEvent('ox_lib:notify', {
            title = 'Haudankaivuu',
            description = 'You need to wait before you can dig again!',
            type = 'error'
        })
        return
    end

    if math.random(1, 100) <= Config.NotifyChance then
        exports['Rx-GraveRob']:SendGraveRobberyNotification()
    end

    TriggerServerEvent('rxjg.grave:checkRequirements', location)
end

RegisterNetEvent('rxjg.grave:canDig', function(canDig, location)
    if not canDig then
        TriggerEvent('ox_lib:notify', {
            title = 'Grave Digging',
            description = 'Not enough Polices!',
            type = 'error'
        })
        return
    end

    digging = true
    cooldown = true

    local success = exports.ox_lib:skillCheck({ 'easy', 'medium', 'hard' }, { 'a', 'd', 's' })

    if not success then
        TriggerEvent('ox_lib:notify', {
            title = 'Grave Digging',
            description = 'You failed digging!',
            type = 'error'
        })
        digging = false
        cooldown = false
        return
    end

    exports.ox_lib:progressBar({
        duration = 6000,
        label = 'Digging...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true
        }
    })

    TaskStartScenarioInPlace(PlayerPedId(), "world_human_gardener_plant", 0, true)
    Citizen.Wait(7500)
    ClearPedTasks(PlayerPedId())
    TriggerServerEvent('rxjg.grave:attemptDig')

    digging = false

    Citizen.SetTimeout(Config.Cooldown * 1000, function()
        cooldown = false
    end)
end)
Citizen.CreateThread(function()
    for _, grave in ipairs(Config.GraveLocations) do
        exports.ox_target:addSphereZone({
            coords = grave,
            radius = 1.5,
            options = {
                {
                    name = 'grave_dig',
                    event = 'rxjg.grave:startDigging',
                    icon = 'fa-solid fa-shovel',
                    label = 'Dig Grave'
                }
            }
        })
        if blipsEnabled then
            local blip = AddBlipForCoord(grave)
            SetBlipSprite(blip, 310)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 5)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Grave")
            EndTextCommandSetBlipName(blip)
        end
    end
end)

function ToggleBlips()
    blipsEnabled = not blipsEnabled
    if blipsEnabled then
        for _, grave in ipairs(Config.GraveLocations) do
            if not createdBlips[grave] then
                local blip = AddBlipForCoord(grave)
                SetBlipSprite(blip, 310)
                SetBlipScale(blip, 0.8)
                SetBlipColour(blip, 5)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Grave")
                EndTextCommandSetBlipName(blip)
                createdBlips[grave] = blip
            end
            SetBlipDisplay(createdBlips[grave], true) 
        end
    else
        for _, blip in pairs(createdBlips) do
            SetBlipDisplay(blip, false) 
        end
    end
end
RegisterNetEvent('rxjg.grave:startDigging', function()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, grave in ipairs(Config.GraveLocations) do
        if #(playerCoords - grave) < 1.5 then
            if hasShovel() then
                StartDigging(grave)
            end
            return
        end
    end
    TriggerEvent('ox_lib:notify', {
        title = 'Grave Digging',
        description = 'You arent near a grave!',
        type = 'error'
    })
end)
