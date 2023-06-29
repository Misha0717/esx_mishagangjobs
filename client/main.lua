PlayerData = {}
CurrentGang = nil

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent("esx:playerLoaded", function(Player)
    PlayerData = Player

    StartGangMarkers()
end)

RegisterNetEvent("esx:setJob", function(job)
    PlayerData.job = job

    StartGangMarkers()
end)

local MarkerThreadRunning = false
function StartGangMarkers()
    if not IsGang() or MarkerThreadRunning then
        return
    end

    MarkerThreadRunning = true
    while IsGang() and MarkerThreadRunning do
        local sleep     = 1000
        local ped       = PlayerPedId()
        local coords    = GetEntityCoords(ped)
        
        for k,v in pairs(Config.Gangs[CurrentGang]) do
            local dist = #(coords - v)

            if dist < 15 then
                sleep = 0

                DrawMarker(2, v, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 0, 0, 255, 200, true, true, false, true)

                if dist < 2.0 then
                    if IsControlJustPressed(0, 38) then
                        OpenMenuHandler(k)
                    end
                end

            end
        end

        Citizen.Wait(sleep)
    end

    MarkerThreadRunning = false
end