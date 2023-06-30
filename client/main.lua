PlayerData = {}
CurrentGang = nil

Citizen.CreateThread(function()
    while not ESX.IsPlayerLoaded() do
        Wait(500)
    end

    PlayerData = ESX.GetPlayerData()
    Wait(1000)
    StartGangMarkers()
end)

RegisterNetEvent("esx:playerLoaded", function(Player)
    PlayerData = Player

    StartGangMarkers()
end)

RegisterNetEvent("esx:setJob", function(job)
    PlayerData.job = job

    StartGangMarkers()
end)

RegisterNetEvent("esx:setAccountMoney", function(account)
    for i=1, #PlayerData.accounts do
        if PlayerData.accounts[i].name == account.name then
            PlayerData.accounts[i].money = account.money
            break
        end
    end
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
            for i=1, #Config.Gangs[CurrentGang][k] do
                local dist = #(coords - Config.Gangs[CurrentGang][k][i])
                if dist < 15 then
                    sleep = 0
    
                    DrawMarker(1, Config.Gangs[CurrentGang][k][i], 0, 0, 0, 0, 0, 0, 1.5, 1.5, 1.0, 0, 0, 255, 200, false, false, false, true)
    
                    if dist < 2.0 then
                        ESX.ShowHelpNotification("Press ~INPUT_CONTEXT~ to open menu "..k, thisFrame, bepp, duration)
                        if IsControlJustPressed(0, 38) then
                            OpenMenuHandler(k)
                        end
                    end
    
                end
            end
        end

        Citizen.Wait(sleep)
    end

    MarkerThreadRunning = false
end