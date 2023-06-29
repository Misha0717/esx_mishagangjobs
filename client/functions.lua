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
    local ArmoryInventory = PromiseCb("esx_mishagangjobs:GetArmory", CurrentGang)
    local elements = {}

    for k,v in pairs(ArmoryInventory) do
        table.insert(elements, {
            item = v.item,
            label = ("%sx %s"):format(v.count, v.item)
        })
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
        print("[esx_MishaGangJobs] ^9[Error]^0 "..CallbackName.." timed-out!")
        return result
    end

    return result
end