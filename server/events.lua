RegisterServerEvent("esx_mishagangjobs:PutItemInArmory", function(Gang, item, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not Config.Gangs[xPlayer.getJob().name] then
        print(("^3[esx_mishagangjobs:PutItemInArmory] ^8[CheatFlag]^0 %s(%s): Tried to put item in armory with job %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), xPlayer.getJob().name
        ))
        DropPlayer(source, "esx_mishagangjobs:PutItemInArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local NearMarker,Dist = NearMarker(source, "Armory", 10)
    if not NearMarker then
        print(("^3[esx_mishagangjobs:PutItemInArmory] ^8[CheatFlag]^0 %s(%s): Tried to put item in armory while %.2f meters away from marker!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:PutItemInArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    if not HasItemInInventory(source, item) then
        print(("^3[esx_mishagangjobs:PutItemInArmory] ^8[CheatFlag]^0 %s(%s): Tried to put item in armory while %s is not in his inventory!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), item
        ))
        DropPlayer(source, "esx_mishagangjobs:PutItemInArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    if item == "money" or item == "black_money" then
        xPlayer.removeAccountMoney(item, tonumber(count))
    else
        xPlayer.removeInventoryItem(item, tonumber(count))
    end

    local currentInventory = MySQL.prepare.await('SELECT `inventory` FROM `misha_gangjobs` WHERE `gang` = ?', { Gang })
    currentInventory = json.decode(currentInventory)
    
    if not currentInventory[item] then
        currentInventory[item] = count
    else
        currentInventory[item] = math.floor(currentInventory[item] + count)
    end

    MySQL.update.await('UPDATE misha_gangjobs SET inventory = ? WHERE gang = ?', {
        json.encode(currentInventory), Gang
    })
    
    TriggerClientEvent("esx:showNotification", source, ("You put ~y~%sx~b~ %s~w~ in your gang armory."):format(count, item))
end)

RegisterServerEvent("esx_mishagangjobs:TakeItemFromArmory", function(Gang, item, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not Config.Gangs[xPlayer.getJob().name] then
        print(("^3[esx_mishagangjobs:TakeItemFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to take item from armory with job %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), xPlayer.getJob().name
        ))
        DropPlayer(source, "esx_mishagangjobs:TakeItemFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local NearMarker,Dist = NearMarker(source, "Armory", 10)
    if not NearMarker then
        print(("^3[esx_mishagangjobs:TakeItemFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to take item from armory while %.2f meters away from marker!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:TakeItemFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local ItemInGangArmory, AmountInGangArmory = HasItemInGangArmory(source, item, Gang)
    if not ItemInGangArmory then
        print(("^3[esx_mishagangjobs:TakeItemFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to take item from armory while %s is not in gang armory!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), item
        ))
        DropPlayer(source, "esx_mishagangjobs:TakeItemFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    if tonumber(count) > tonumber(AmountInGangArmory) then
        print(("^3[esx_mishagangjobs:TakeItemFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to take item from armory while client sided count is %s and serversided count %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), count, AmountInGangArmory
        ))
        DropPlayer(source, "esx_mishagangjobs:TakeItemFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    if item == "money" or item == "black_money" then
        xPlayer.addAccountMoney(item, tonumber(count))
    else
        xPlayer.removeInventoryItem(item, tonumber(count))
    end
    local currentInventory = MySQL.prepare.await('SELECT `inventory` FROM `misha_gangjobs` WHERE `gang` = ?', { Gang })
    currentInventory = json.decode(currentInventory)
    
    if (tonumber(currentInventory[item]) - tonumber(count)) > 0 then
        currentInventory[item] = math.floor(currentInventory[item] - count)
    else
        currentInventory[item] = nil
    end

    MySQL.update.await('UPDATE misha_gangjobs SET inventory = ? WHERE gang = ?', {
        json.encode(currentInventory), Gang
    })

    TriggerClientEvent("esx:showNotification", source, ("You taked ~y~%sx~b~ %s~w~ from your gang armory."):format(count, item))
end)

RegisterServerEvent("esx_mishagangjobs:BuyItemFromShop", function(Gang, item, count)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not Config.Gangs[xPlayer.getJob().name] then
        print(("^3[esx_mishagangjobs:BuyItemFromShop] ^8[CheatFlag]^0 %s(%s): Tried to buy item from armory with job %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), xPlayer.getJob().name
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyItemFromShop: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local NearMarker,Dist = NearMarker(source, "Armory", 10)
    if not NearMarker then
        print(("^3[esx_mishagangjobs:BuyItemFromShop] ^8[CheatFlag]^0 %s(%s): Tried to buy item from armory while %.2f meters away from marker!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyItemFromShop: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    if not Config.ItemShop[item] then
        print(("^3[esx_mishagangjobs:BuyItemFromShop] ^8[CheatFlag]^0 %s(%s): Tried to buy a invalid item(%s) from armory!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyItemFromShop: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local price = Config.ItemShop[item].price*count
    if xPlayer.getAccount('money').money >= price then
        xPlayer.removeAccountMoney('money', price)
        xPlayer.addInventoryItem(item, count)
    else
        TriggerClientEvent("esx:showNotification", source, "You cant buy this item!")
    end
end)

RegisterServerEvent("esx_mishagangjobs:BuyWeaponFromArmory", function(gang, Weapon)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not Config.Weapons[xPlayer.getJob().name] then
        print(("^3[esx_mishagangjobs:BuyWeaponFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to buy weapon from armory with job %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), xPlayer.getJob().name
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyWeaponFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local NearMarker,Dist = NearMarker(source, "Armory", 10)
    if not NearMarker then
        print(("^3[esx_mishagangjobs:BuyWeaponFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to buy weapon from armory while %.2f meters away from marker!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyWeaponFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local WeaponData = Config.Weapons[xPlayer.getJob().name][xPlayer.getJob().grade][Weapon]
    if not WeaponData then
        print(("^3[esx_mishagangjobs:BuyWeaponFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to buy weapon from armory while weapon(%s) is not in the shop!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Weapon
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyWeaponFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local price = WeaponData
    if xPlayer.getAccount('money').money >= price then
        if xPlayer.hasWeapon(Weapon) then
            TriggerClientEvent("esx:showNotification", source, "You have already this weapon!")
            return
        end

        xPlayer.removeAccountMoney('money', price)
        xPlayer.addWeapon(Weapon, 0)
    else
        TriggerClientEvent("esx:showNotification", source, "You cant buy this weapon!")
    end
end)

RegisterServerEvent("esx_mishagangjobs:BuyWeaponAttachment", function(gang, Weapon, Component)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not Config.Weapons[xPlayer.getJob().name] then
        print(("^3[esx_mishagangjobs:BuyWeaponAttachment] ^8[CheatFlag]^0 %s(%s): Tried to buy weaponcomponent from armory with job %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), xPlayer.getJob().name
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyWeaponAttachment: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local NearMarker,Dist = NearMarker(source, "Armory", 10)
    if not NearMarker then
        print(("^3[esx_mishagangjobs:BuyWeaponAttachment] ^8[CheatFlag]^0 %s(%s): Tried to buy weaponcomponent from armory while %.2f meters away from marker!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyWeaponAttachment: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local WeaponData = Config.Weapons[xPlayer.getJob().name][xPlayer.getJob().grade][Weapon]
    if not WeaponData then
        print(("^3[esx_mishagangjobs:BuyWeaponAttachment] ^8[CheatFlag]^0 %s(%s): Tried to buy weaponcomponent from armory while weapon(%s) is not in the shop!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Weapon
        ))
        DropPlayer(source, "esx_mishagangjobs:BuyWeaponAttachment: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local price = WeaponData*Config.WeaponAttachmentMultiplier[Weapon][Component]
    if xPlayer.getAccount('money').money >= price then
        if not xPlayer.hasWeapon(Weapon) then
            TriggerClientEvent("esx:showNotification", source, "You dont have this weapon!")
            return
        end

        xPlayer.removeAccountMoney('money', price)
        xPlayer.addWeaponComponent(Weapon, Component)
    else
        TriggerClientEvent("esx:showNotification", source, "You cant buy this weapon!")
    end
end)

RegisterServerEvent("esx_mishagangjobs:PutWeaponToArmory", function(Weapon)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not Config.Gangs[xPlayer.getJob().name] then
        print(("^3[esx_mishagangjobs:PutWeaponToArmory] ^8[CheatFlag]^0 %s(%s): Tried to put weapon to armory with job %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), xPlayer.getJob().name
        ))
        DropPlayer(source, "esx_mishagangjobs:PutWeaponToArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local NearMarker,Dist = NearMarker(source, "Armory", 10)
    if not NearMarker then
        print(("^3[esx_mishagangjobs:PutWeaponToArmory] ^8[CheatFlag]^0 %s(%s): Tried to put weapon to armory while %.2f meters away from marker!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:PutWeaponToArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    if not xPlayer.hasWeapon(Weapon) then
        print(("^3[esx_mishagangjobs:PutWeaponToArmory] ^8[CheatFlag]^0 %s(%s): Tried to put weapon to armory while weapon(%) is not in his inventory!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Weapon
        ))
        DropPlayer(source, "esx_mishagangjobs:PutWeaponToArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    xPlayer.removeWeapon(Weapon)
    local currentWeapons = MySQL.prepare.await('SELECT `weapons` FROM `misha_gangjobs` WHERE `gang` = ?', { xPlayer.getJob().name })
    currentWeapons = json.decode(currentWeapons)
    
    for k,v in pairs(xPlayer.loadout) do
        if v.name == Weapon then
            table.insert(currentWeapons, {
                weapon = v.name,
                ammo = v.ammo,
                components = v.components
            })
        end
    end

    MySQL.update.await('UPDATE misha_gangjobs SET weapons = ? WHERE gang = ?', {
        json.encode(currentWeapons), xPlayer.getJob().name
    })
end)

RegisterServerEvent("esx_mishagangjobs:TakeWeaponFromArmory", function(weapon, ammo, components)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)

    if not Config.Gangs[xPlayer.getJob().name] then
        print(("^3[esx_mishagangjobs:TakeWeaponFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to take weapon from armory with job %s!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), xPlayer.getJob().name
        ))
        DropPlayer(source, "esx_mishagangjobs:TakeWeaponFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local NearMarker,Dist = NearMarker(source, "Armory", 10)
    if not NearMarker then
        print(("^3[esx_mishagangjobs:TakeWeaponFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to take weapon from armory while %.2f meters away from marker!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), Dist
        ))
        DropPlayer(source, "esx_mishagangjobs:TakeWeaponFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local WeaponInGangArmory = HasWeaponInGangArmory(weapon, xPlayer.getJob().name)
    if not WeaponInGangArmory then
        print(("^3[esx_mishagangjobs:TakeWeaponFromArmory] ^8[CheatFlag]^0 %s(%s): Tried to take weapon from armory while %s is not in gang armory!"):format(
            GetPlayerName(source), GetPlayerIdentifier(source, 0), weapon
        ))
        DropPlayer(source, "esx_mishagangjobs:TakeWeaponFromArmory: "..GetPlayerName(source).." Tried to exploit the armory!")
        return
    end

    local currentWeapons = MySQL.prepare.await('SELECT `weapons` FROM `misha_gangjobs` WHERE `gang` = ?', { xPlayer.getJob().name })
    local FoundWeapon = false
    currentWeapons = json.decode(currentWeapons)
    for k,v in pairs(currentWeapons) do
        if v.weapon == weapon then
            if v.ammo == ammo then
                FoundWeapon = true
                table.remove(currentWeapons, k)
                break
            end
        end
    end

    if not FoundWeapon then
        TriggerClientEvent("esx:showNotification", source, "there was goes something wrong with taking your weapon. Please try again!")
        return 
    end

    MySQL.update.await('UPDATE misha_gangjobs SET weapons = ? WHERE gang = ?', {
        json.encode(currentWeapons), xPlayer.getJob().name
    })

    xPlayer.addWeapon(weapon, ammo)
    if components then
        for k,v in pairs(components) do
            xPlayer.addWeaponComponent(weapon, v)
        end
    end

    TriggerClientEvent("esx:showNotification", source, ("You taked a ~b~%s~w~ from your gang armory."):format(ESX.GetWeaponLabel(weapon)))
end)