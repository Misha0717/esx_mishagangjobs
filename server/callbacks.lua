ESX.RegisterServerCallback('esx_mishagangjobs:GetArmory', function(source, cb, gang)
    cb(GetCurrentInventoryFromGang(source, gang))
end)

ESX.RegisterServerCallback('esx_mishagangjobs:GetPlayerInventory', function(source, cb, TargetId)
    local xPlayer = ESX.GetPlayerFromId(TargetId or source)

    cb(xPlayer.getInventory(true))
end)

ESX.RegisterServerCallback('esx_mishagangjobs:GetWeaponsInArmory', function(source, cb, TargetId)
    local xPlayer = ESX.GetPlayerFromId(TargetId or source)

    cb(GetCurrentInventoryFromGang(source, xPlayer.getJob().name))
end)