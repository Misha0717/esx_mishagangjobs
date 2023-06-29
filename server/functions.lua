function GetCurrentInventoryFromGang(gang)
    local inventory = MySQL.prepare.await('SELECT `inventory` FROM `misha_gangjobs` WHERE `gang` = ?', {
        gang
    })

    if not inventory then
        MySQL.insert.await('INSERT INTO `misha_gangjobs` (gang) VALUES (?)', {
            gang
        })
    end

    return json.decode(inventory)
end

function NearMarker(source, ConfigType, maxDist)
    local coords = GetEntityCoords(GetPlayerPed(source))

    if not Config.Gangs[ESX.GetPlayerFromId(source).getJob().name][ConfigType] then
        print(("^3esx_mishagangjobs ^8[Error]^0 Tried to calculate distance near marker while MarkerType was not valid(%s)!"):format(
            ConfigType
        ))
        return true
    end

    for k,v in pairs(Config.Gangs[ESX.GetPlayerFromId(source).getJob().name][ConfigType]) do
        local dist = #(coords - v)

        if dist > maxDist then
            return false, dist
        end 
    end
    return true
end

function HasItemInInventory(source, item)
    local xPlayer = ESX.GetPlayerFromId(source)
    local inventory = xPlayer.getInventory(true)

    if not inventory[item] then
        return false
    end

    return true
end

function HasItemInGangArmory(source, item, gang)
    local inventory = MySQL.prepare.await('SELECT `inventory` FROM `misha_gangjobs` WHERE `gang` = ?', {
        gang
    })

    if not inventory then
        return false
    end

    inventory = json.decode(inventory)

    if inventory[item] then
        return true, inventory[item]
    end

    return false
end