

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

function OpenArmory()
    if not Config.OX then
        local elements = {
            { label = "Take item from armory", value = "take_item" },
            { label = "Put item in armory", value = "put_item" },
            { label = "Take weapon from armory", value = "take_weapon" },
            { label = "Put weapon in armory", value = "put_weapon" },
            { label = "Buy Items", value = "buy_item" },
            { label = "Buy Weapons", value = "buy_weapons" },
            { label = "Buy Weapon Attachments", value = "buy_weapon_attachments" }
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
            elseif selectedMenu == "take_weapon" then
                OpenTakeWeaponFromArmoryMenu()
            elseif selectedMenu == "put_weapon" then
                OpenPutWeaponFromArmoryMenu()
            elseif selectedMenu == "buy_item" then
                OpenBuyItemMenu()
            elseif selectedMenu == "buy_weapons" then
                OpenBuyWeaponMenu()
            elseif selectedMenu == "buy_weapon_attachments" then
                OpenBuyWeaponAttachmentsMenu()
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
        if k == "money" or k == "black_money" then
            table.insert(elements, {
                label = ("<span style='color:green'>%sx</span> - %s"):format(v, k == "black_money" and "Black Money" or k == "money" and "Money"),
                count = v,
                item = k
            })
        else
            table.insert(elements, {
                label = ("%sx - %s"):format(v, k),
                count = v,
                item = k
            })
        end
    end

    if not next(ArmoryInventory) then
        table.insert(elements, {
            label = "0 items in the armory"
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "take_item", {
        title = "Take Item",
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

    for k,v in pairs(PlayerInventory) do
        table.insert(elements, {
            label = ("%sx - %s"):format(v, k),
            count = v,
            item = k
        })
    end

    for i=1, #PlayerData.accounts do
        local Account = PlayerData.accounts[i]

        if Account.name == "money" then
            if Account.money > 0 then
                table.insert(elements, {
                    label = ("<span style='color:green'>%sx</span> - %s"):format(Account.money, "Money"),
                    count = Account.money,
                    item = "money"
                })
            end
        elseif Account.name == "black_money" then
            if Account.money > 0 then
                table.insert(elements, {
                    label = ("<span style='color:green'>%sx</span> - %s"):format(Account.money, "Black Money"),
                    count = Account.money,
                    item = "black_money"
                })
            end
        end
    end

    if not next(PlayerInventory) then
        table.insert(elements, {
            label = "0 items in your inventory."
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "put_item", {
        title = "Put Item",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.item then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "put_item_dialog", {
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

function OpenTakeWeaponFromArmoryMenu()
    local WeaponsInArmory = PromiseCb("esx_mishagangjobs:GetWeaponsInArmory")
    local elements = {}

    for k,v in pairs(WeaponsInArmory) do
        table.insert(elements, {
            label = ESX.GetWeaponLabel(v.weapon),
            weapon = v.weapon,
            ammo = v.ammo,
            components = v.components
        })
    end
    
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "take_weapon", {
        title = "Take Weapon",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.weapon then
            if not HasPedGotWeapon(PlayerPedId(), GetHashKey(data.current.weapon), false) then
                TriggerServerEvent("esx_mishagangjobs:TakeWeaponFromArmory", data.current.weapon, data.current.ammo, data.current.components)
                menu.close()
            else
                ESX.ShowNotification("You ~r~already~w~ have this weapon!")
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenPutWeaponFromArmoryMenu()
    local elements = {}
    local WeaponList = ESX.GetWeaponList()
    local ped = PlayerPedId()

    for k,v in ipairs(WeaponList) do
        if HasPedGotWeapon(ped, GetHashKey(v.name), false) then
            table.insert(elements, {
                label = ESX.GetWeaponLabel(v.name),
                weapon = v.name
            })
        end
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "put_weapon", {
        title = "Put Weapon",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.weapon then
            TriggerServerEvent("esx_mishagangjobs:PutWeaponToArmory", data.current.weapon)
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenBuyItemMenu()
    local elements = {}

    for k,v in pairs(Config.ItemShop) do
        table.insert(elements, {
            label = ("<span style='color:green;'>€%s</span> - %s"):format(v.price, v.label),
            item = k,
            price = v.price
        })
    end

    if not next(elements) then
        table.insert(elements, {
            label = "You cant buy items in your shop!",
        })
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "buy_item", {
        title = "Buy Item",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.item then
            ESX.UI.Menu.Open("dialog", GetCurrentResourceName(), "buy_item_dialog", {
                title = "Amount"
            }, function(data2, menu2)
                local Amount = data2.value
                if Amount then
                    TriggerServerEvent("esx_mishagangjobs:BuyItemFromShop", CurrentGang, data.current.item, Amount)
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

function OpenBuyWeaponMenu()
    local elements = {}

    for k,v in pairs(Config.Weapons[CurrentGang][PlayerData.job.grade]) do
        table.insert(elements, {
            label = ("<span style='color:green;'>€%s</span> - %s"):format(v, ESX.GetWeaponLabel(k)),
            weapon = k,
            price = v
        })
    end

    if not next(elements) then
        table.insert(elements, {
            label = "You cant buy weapons in your shop!",
        })
    end

    table.sort(elements, function(a, b)
        return a.price < b.price
    end)

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "buy_weapon", {
        title = "Buy Item",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.weapon then
            TriggerServerEvent("esx_mishagangjobs:BuyWeaponFromArmory", CurrentGang, data.current.weapon)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenBuyWeaponAttachmentsMenu()
    local elements = {}
    local ped = PlayerPedId()

    for k,v in pairs(Config.Weapons[PlayerData.job.name][PlayerData.job.grade]) do
        if HasPedGotWeapon(ped, GetHashKey(k), false) then
            table.insert(elements, {
                label = ESX.GetWeaponLabel(k),
                weapon = k
            })
        end
    end

    if not next(elements) then
        table.insert(elements, {
            label = "You cant add attachments to your weapons!",
        })
    end

    table.sort(elements, function(a, b)
        return a.label < b.label
    end)

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "buy_weapon_attachment", {
        title = "Buy Weapon Attachments",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        local Weapon = data.current.weapon
        if Weapon then
            OpenSelectWeaponAttachmentMenu(Weapon)
        end
    end, function(data, menu)
        menu.close()
    end)
end

function OpenSelectWeaponAttachmentMenu(weapon)
    local elements = {}
    local ComponentsFromWeapon = GetComponentsFromWeapon(weapon)
    local WeaponPrice = Config.Weapons[PlayerData.job.name][PlayerData.job.grade][weapon]

    for k,v in ipairs(ComponentsFromWeapon) do
        local price = WeaponPrice*Config.WeaponAttachmentMultiplier[weapon][v.name]
        if not HasPedGotWeaponComponent(PlayerPedId(), GetHashKey(weapon), v.hash) then
            table.insert(elements, {
                label = ("<span style='color:green;'>€%s</span> - %s"):format(math.floor(price), v.label),
                name = v.name,
                hash = v.hash,
                price = price
            })
        else
            table.insert(elements, {
                label = ("<span style='color:green;'>equipped</span> - %s"):format(v.label),
            })
        end
    end

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "buy_weapon_attachment_menu", {
        title = "Buy Weapon Attachments",
        align = "top-right",
        elements = elements
    }, function(data, menu)
        if data.current.name then
            if not HasPedGotWeaponComponent(PlayerPedId(), GetHashKey(weapon), data.current.hash) then
                TriggerServerEvent("esx_mishagangjobs:BuyWeaponAttachment", CurrentGang, weapon, data.current.name)
                menu.close()
            else
                ESX.ShowNotification("You ~r~already~w~ have this weapon attachment!")
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end

function GetComponentsFromWeapon(weapon)
    local WeaponList = ESX.GetWeaponList()
    for k,v in ipairs(WeaponList) do
        if v.name == weapon then
            return v.components
        end
    end
end