local Dispatch = {}

function Dispatch.SendGraveRobberyNotification()
    local data = exports['cd_dispatch']:GetPlayerInfo()
    TriggerServerEvent('cd_dispatch:AddNotification', {
        job_table = {'police'},
        coords = data.coords,
        title = '10-15 - Grave Digging',
        message = 'A '..data.sex..'Digging a Grave'..data.street,
        flash = 1,
        unique_id = data.unique_id,
        sound = 1,
        blip = {
            sprite = 310,
            scale = 1.2,
            colour = 1,
            flashes = true,
            text = '911 - Grave Digging',
            time = 5,
            radius = 0,
        }
    })
end

exports("SendGraveRobberyNotification", Dispatch.SendGraveRobberyNotification)
