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

    xPlayer.removeInventoryItem(item, count)
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

    xPlayer.removeInventoryItem(item, count)
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