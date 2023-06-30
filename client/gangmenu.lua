RegisterCommand('gang_menu_open', function(source, args, RawCommand)
    OpenGangMenu()
end)

RegisterKeyMapping("gang_menu_open", "Open your gang menu", "keyboard", "F6")

function OpenGangMenu()
    local elements = {}
    local NearbyPlayers = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 5)

    for k,v in pairs(NearbyPlayers) do
        table.insert(elements, {
            label = tostring(GetPlayerServerId(k)),
            serverid = GetPlayerServerId(k)
        })
    end

    if not next(elements) then
        table.insert(elements, {
            label = "No nearby player!",
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "gang_menu", {
        title = PlayerData.job.label.." Menu",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.serverid then
            local elements = {
                { label = "Cuff", value = "cuff_player" },
                { label = "Uncuff", value = "uncuff_player" },
                { label = "Drag", value = "cuff_player" },
                { label = "Put in vehicle", value = "put_in_vehicle" },
                { label = "Take out vehicle", value = "take_out_vehicle" },
                { label = "Search", value = "body_search" }
            }

            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "gang_menu", {
                title = PlayerData.job.label.." Menu",
                align = "top-right",
                elements = elements
            }, function(data3, menu3)

            end, function(data3, menu3)
                menu3.close()
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end