ESX.RegisterServerCallback('esx_mishagangjobs:GetArmory', function(source, cb, gang)
    cb(GetCurrentInventoryFromGang(gang))
end)

ESX.RegisterServerCallback('esx_mishagangjobs:GetPlayerInventory', function(source, cb, TargetId)
    local xPlayer = ESX.GetPlayerFromId(TargetId or source)

    cb(xPlayer.getInventory(true))
end)