function IsGang()
    if PlayerData.job ~= nil and Config.Gangs[PlayerData.job.name] then
        CurrentGang = PlayerData.job.name
        return true
    end
    
    return false
end

function OpenMenuHandler(Action)
    if Action == "Armory" then
        OpenArmory()
    end
end

function OpenArmory()
    if not Config.OX then
        local elements = {
            { label = "Take item from armory", value = "take_item" },
            { label = "Put item in armory", value = "put_item" },
            { label = "Buy Items", value = "buy_item" },
            { label = "Buy Weapons", value = "buy_weapons" }
        }

        ESX.UI.Menu.Open("default", GetCurrentResourceName(), "open_armory", {
            title = "Armory",
            align = "top-right",
            elements = elements
        }, function(data, menu)
            local selectedMenu = data.current.value

            if selectedMenu == "take_item" then
                OpenTakeItemFromArmoryMenu()
            elseif selectedMenu == "put_item" then
                OpenPutItemFromArmoryMenu()
            elseif selectedMenu == "but_item" then

            elseif selectedMenu == "buy_weapons" then

            end
        end, function(data, menu)
            menu.close()
        end)
    end
end

function OpenTakeItemFromArmoryMenu()
    local ArmoryInventory = PromiseCb("esx_mishagangjobs:GetArmory", CurrentGang)
    local elements = {}

    for k,v in pairs(ArmoryInventory) do
        table.insert(elements, {
            label = ("%sx - %s"):format(v, k),
            count = v,
            item = k
        })
    end

    if not next(ArmoryInventory) then
        table.insert(elements, {
            label = "0 items in the armory"
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "take_item", {
        title = "Armory",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.item then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "take_item_dialog", {
                title = "Amount"
            }, function(data2, menu2)
                local Amount = data2.value
                if Amount then
                    TriggerServerEvent("esx_mishagangjobs:TakeItemFromArmory", CurrentGang, data.current.item, Amount)
                    menu2.close()
                    menu.close()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenPutItemFromArmoryMenu()
    local PlayerInventory = PromiseCb("esx_mishagangjobs:GetPlayerInventory")
    local elements = {}

    print(json.encode(PlayerInventory))
    for k,v in pairs(PlayerInventory) do
        table.insert(elements, {
            label = ("%sx - %s"):format(v, k),
            count = v,
            item = k
        })
    end

    if not next(PlayerInventory) then
        table.insert(elements, {
            label = "0 items in your inventory."
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "take_item", {
        title = "Armory",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.item then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "take_item_dialog", {
                title = "Amount"
            }, function(data2, menu2)
                local Amount = data2.value
                if Amount then
                    TriggerServerEvent("esx_mishagangjobs:PutItemInArmory", CurrentGang, data.current.item, Amount)
                    menu2.close()
                    menu.close()
                end
            end, function(data2, menu2)
                menu2.close()
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function PromiseCb(CallbackName, ...)
    local p = promise.new()

    ESX.TriggerServerCallback(CallbackName, function(...)
        p:resolve(...)
    end, ...)

    SetTimeout(2000,  function()
        p:resolve(false)
    end)

    local result = Citizen.Await(p)

    if not result then
        print("^3[esx_MishaGangJobs] ^9[Error]^0 "..CallbackName.." timed-out!")
        return result
    end

    return result
end