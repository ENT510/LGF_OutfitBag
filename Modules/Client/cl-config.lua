local Config = {}

Config.interact = 'LGF_SpriteTextUI' -- 'LGF_SpriteTextUI' or 'ox_target'

-- "fivem-appearance", "illenium-appearance", or "bl-appearance"
Config.HandlerAppearance = "fivem-appearance"


Config.BagData = {
    {
        itemName = "outfitbag_10",
        propName = "prop_cs_heist_bag_02",
        maxSlot = 4,
    }
}

-- Only get components (clothes) and props (accessories) to prevent Change model/headblend ecc

Config.GetSkin = function(Ped)
    if Config.HandlerAppearance == "fivem-appearance" or Config.HandlerAppearance == "illenium-appearance" then
        local Components = exports[Config.HandlerAppearance]:getPedComponents(Ped)
        local Props = exports[Config.HandlerAppearance]:getPedProps(Ped)
        return { Components = Components, Props = Props }
    elseif Config.HandlerAppearance == "bl-appearance" then
        local Skin = exports.bl_appearance:GetDrawables(Ped)
        local Props = exports.bl_appearance:GetPedProps(Ped)
        return { Components = Skin, Props = Props }
    end
end


Config.SetSkin = function(Ped, skin)
    local Components = skin.Components
    local Props = skin.Props
    if Config.HandlerAppearance == "fivem-appearance" or Config.HandlerAppearance == "illenium-appearance" then
        exports[Config.HandlerAppearance]:setPedComponents(Ped, Components)
        exports[Config.HandlerAppearance]:setPedProps(Ped, Props)
    elseif Config.HandlerAppearance == "bl-appearance" then
        exports.bl_appearance:SetPedClothes(Ped, Components)
        exports.bl_appearance:SetPedProps(Ped, Props)
    end
end

-- Prevent Opening Bag when player is dead
Config.DeatCheck = function(ped)
    return LocalPlayer.state.dead
end

return Config
