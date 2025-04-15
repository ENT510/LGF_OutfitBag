local config = lib.load('Modules.Shared.client')

-- Only get components (clothes) and props (accessories) to prevent Change model/headblend ecc
local function GetSkin(Ped)
    if config.handlerAppearance == 'fivem-appearance' or config.handlerAppearance == 'illenium-appearance' then
        local Components = exports[config.handlerAppearance]:getPedComponents(Ped)
        local Props = exports[config.handlerAppearance]:getPedProps(Ped)
        return { Components = Components, Props = Props }
    elseif config.handlerAppearance == 'bl-appearance' then
        local Skin = exports.bl_appearance:GetDrawables(Ped)
        local Props = exports.bl_appearance:GetPedProps(Ped)
        return { Components = Skin, Props = Props }
    end
end

local function SetSkin(Ped, skin)
    local Components = skin.Components
    local Props = skin.Props
    if config.handlerAppearance == 'fivem-appearance' or config.handlerAppearance == 'illenium-appearance' then
        exports[config.handlerAppearance]:setPedComponents(Ped, Components)
        exports[config.handlerAppearance]:setPedProps(Ped, Props)
    elseif config.handlerAppearance == 'bl-appearance' then
        exports.bl_appearance:SetPedClothes(Ped, Components)
        exports.bl_appearance:SetPedProps(Ped, Props)
    end
end
-- Prevent Opening Bag when player is dead
local function DeatCheck(ped)
    return LocalPlayer.state.dead
end

local function GetCharSlot()
    if GetResourceState('LEGACYCORE'):find('start') then
        local LGF = exports.LEGACYCORE:GetCoreData()
        local Slot = LGF.DATA:GetSlotCharacter()
        return Slot
    else
        return nil
    end
end

return {
    GetSkin = GetSkin,
    SetSkin = SetSkin,
    DeatCheck = DeatCheck,
    GetCharSlot = GetCharSlot
}
