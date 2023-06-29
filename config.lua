Config = {}
Config.OX = false
Config.ItemShop = {
    lockpick = { price = 1000, label = "LockPicks" }
}

Config.Gangs = {
    ["biker"] = {
        ["Armory"] = {
            vector3(1401.3159, 1132.2335, 113.3337)
        },
    }
}

Config.Weapons = {
    ["biker"] = {
        [0] = {
            ["WEAPON_PISTOL"] = 70000,
            ["WEAPON_SAWNOFFSHOTGUN"] = 100000
        },

        [1] = {
            ["WEAPON_PISTOL"] = 70000,
            ["WEAPON_SAWNOFFSHOTGUN"] = 100000,
            ["WEAPON_ASSAULTRIFLE"] =  150000,
        }
    }
}

Config.WeaponAttachmentMultiplier = {
    ["WEAPON_PISTOL"] = {
        clip_default = 0,
        clip_extended = 0.5,
        flashlight = 0.3,
        suppressor = 0.4,
        luxary_finish = 0.7
    }
}