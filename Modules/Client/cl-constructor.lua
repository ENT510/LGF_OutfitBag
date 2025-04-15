Bag = {
    bags = {},
}
IsInCode = false
InputOpened = false
AlertOpened = false
local Config = lib.load('Modules.Shared.client')
local Cam = lib.load('Modules.Client.cl-cam')
local bridge = lib.load('Modules.Client.bridge')

function Bag:setup()
    self.animDict = 'pickup_object'
    self.animName = 'pickup_low'
    self.dictChangeClothes = 'anim_heist@hs3f@ig12_change_clothes@'
    self.animChangeCLothes = 'action_01_male'
end

function Bag:animChangeClothes(time)
    local dict = lib.requestAnimDict(self.dictChangeClothes)
    local name = self.animChangeCLothes
    TaskPlayAnim(cache.ped, dict, name, 1.0, 1.0, -1, 1, 0.5, false, false, false)
    SetTimeout(time, function()
        RemoveAnimDict(dict)
        ClearPedTasks(cache.ped)
    end)
end

function Bag:animAndCam(enable)
    enable = enable or true
    local dict = lib.requestAnimDict('amb@world_human_bum_wash@male@low@idle_a')
    local name = 'idle_a'
    local ped = cache.ped
    if enable then
        if not Cam.GetCam() then Cam.CamPed() end
    end
    TaskPlayAnim(ped, dict, name, 1.0, 1.0, -1, 1, 0.5, false, false, false)
end

function Bag:animAndCamClear(stopCam)
    local dict = lib.requestAnimDict('amb@world_human_bum_wash@male@low@idle_a')
    RemoveAnimDict(dict)
    ClearPedTasks(cache.ped)
    if stopCam then
        if Cam.GetCam() then Cam.DestroyCam() end
    end
end

function Bag:andleCodeInput(idDui)
    IsInCode = true
    local input = lib.inputDialog(locale('menu.add_outfit_code_title'), {
        { type = 'input', label = locale('menu.add_outfit_code_label'), description = locale('menu.add_outfit_code_desc'), required = true, min = 4, max = 16 },
    })
    if not input then
        lib.showContext(('bag_menu_%s'):format(idDui))
        IsInCode = false
        return
    end
    local codeName = input[1]
    local success = lib.callback.await('LGF_OutfitBagOx.addOutfitByCode', 200, {
        codeName = codeName,
        bagIDToAdd = idDui,
    })
    if not success then return end
    IsInCode = false
    lib.showContext(('bag_menu_%s'):format(idDui))
end

function Bag:PlaceBag(propName, maxSlot, itemName, bagID)
    Bag:setup()
    lib.requestAnimDict(self.animDict)
    lib.requestModel(propName)
    local coords = GetOffsetFromEntityInWorldCoords(cache.ped, 0.0, 0.5, 0.0)
    TaskPlayAnim(cache.ped, self.animDict, self.animName, 8.0, 8.0, 1000, 50, 0, false, false, false)
    SetTimeout(900, function()
        local entity = CreateObjectNoOffset(propName, coords.x, coords.y, coords.z, true, false)
        PlaceObjectOnGroundProperly(entity)
        bagID = bagID or NetworkGetNetworkIdFromEntity(entity)
        local data = {
            coords = coords,
            bagData = {},
            entity = entity,
            duiHandlers = {},
            bagID = bagID,
            point = nil,
            maxSlot = maxSlot,
            propName = propName,
            savedOutfits = {},
            itemName = itemName,
        }
        Bag.bags[bagID] = data
        lib.callback.await('LGF_OutfitBagOx.syncInteraction', false, data)
    end)
end

RegisterNetEvent('LGF_OutfitBagOx.syncInteraction', function(data)
    local point = lib.points.new({
        coords = data.coords,
        distance = 5,
    })
    local maxSlot = data.maxSlot
    local ItemName = data.itemName
    if not Bag.bags[data.bagID] then Bag.bags[data.bagID] = {} end
    Bag.bags[data.bagID].point = point
    local function interactMenu(idDui)
        Bag:animAndCam()
        local savedOutfits = lib.callback.await('LGF_OutfitBagOx.getOutfitFromId', false, idDui)
        AvailableSlots = maxSlot - #savedOutfits
        local options = {
            {
                title = locale('menu.add_outfit_code_title'),
                description = locale('menu.add_outfit_code_desc'),
                icon = 'key',
                disabled = (type(savedOutfits) == 'table' and #savedOutfits >= maxSlot) or false,
                onSelect = function()
                    Bag:andleCodeInput(idDui)
                end
            },
            {
                title = locale('menu.save_outfit_title'),
                description = locale('menu.save_outfit_desc'),
                icon = 'save',
                disabled = (type(savedOutfits) == 'table' and #savedOutfits >= maxSlot) or false,
                onSelect = function()
                    local Skin = bridge.GetSkin(cache.ped)
                    lib.hideContext()
                    InputOpened = true
                    local input = lib.inputDialog(locale('menu.outfitbag_title', idDui), {
                        { type = 'input', label = locale('menu.outfit_name_label'), description = locale('menu.outfit_name_desc'), required = true, min = 4, max = 16 },
                    })
                    if not input then
                        lib.showContext(('bag_menu_%s'):format(idDui))
                        InputOpened = false
                        return
                    end
                    local OutfitName = input[1]
                    local Slot = bridge.GetCharSlot()
                    lib.callback.await('LGF_OutfitBagOx.saveCurrentOutfit', false, Skin, idDui, OutfitName, Slot)
                    lib.hideContext()
                    Bag:animAndCamClear(true)
                    InputOpened = false
                end
            },
            {
                title = locale('menu.load_outfit_title'),
                description = locale('menu.load_outfit_desc'),
                icon = 'folder-open',
                onSelect = function()
                    local outfitOptions = {}
                    local forceOutf = lib.callback.await('LGF_OutfitBagOx.getOutfitFromId', false, idDui)
                    for _, outfit in ipairs(forceOutf) do
                        outfitOptions[#outfitOptions + 1] = {
                            title = outfit.outfit_name,
                            icon = 'tshirt',
                            description = locale('menu.outfit_code_desc', outfit.outfit_code),
                            onSelect = function()
                                local actionOptions = {
                                    {
                                        title = locale('menu.load_outfit_action'),
                                        description = locale('menu.load_outfit_action_desc'),
                                        icon = 'arrow-right',
                                        onSelect = function()
                                            lib.showContext(('outfit_action_menu_%s'):format(idDui))
                                            Bag:animChangeClothes(1000)
                                            Wait(2000)
                                            bridge.SetSkin(cache.ped, outfit.outfit_data)
                                            Bag:animAndCam(false)
                                        end
                                    },
                                    {
                                        title = locale('menu.delete_outfit_action'),
                                        description = locale('menu.delete_outfit_action_desc'),
                                        icon = 'trash',
                                        onSelect = function()
                                            AlertOpened = true
                                            local alert = lib.alertDialog({
                                                header = locale('menu.confirm_deletion_header', outfit.outfit_code),
                                                content = locale('menu.confirm_deletion_content'),
                                                centered = true,
                                                cancel = true,
                                                labels = {
                                                    confirm = locale('menu.confirm_deletion_confirm'),
                                                    cancel = locale('menu.confirm_deletion_cancel'),
                                                },
                                            })
                                            if alert == 'confirm' then
                                                lib.callback.await('LGF_OutfitBagOx.deleteOutfit', false, {bagID = idDui, outfit_code = outfit.outfit_code})
                                                lib.hideContext()
                                                Bag:animAndCamClear(true)
                                            else
                                                lib.showContext(('bag_menu_%s'):format(idDui))
                                            end
                                            AlertOpened = false
                                        end
                                    }
                                }
                                lib.registerContext({
                                    id = ('outfit_action_menu_%s'):format(idDui),
                                    title = locale('menu.outfit_actions_title', AvailableSlots, maxSlot),
                                    menu = ('saved_outfits_menu_%s'):format(idDui),
                                    canClose = true,
                                    options = actionOptions,
                                })
                                lib.showContext(('outfit_action_menu_%s'):format(idDui))
                            end
                        }
                    end
                    lib.registerContext({
                        id = ('saved_outfits_menu_%s'):format(idDui),
                        title = locale('menu.saved_outfits_title'),
                        menu = ('bag_menu_%s'):format(idDui),
                        canClose = false,
                        options = outfitOptions,
                    })
                    lib.showContext(('saved_outfits_menu_%s'):format(idDui))
                end
            },
            {
                title = locale('menu.take_bag_title'),
                description = locale('menu.take_bag_desc'),
                icon = 'trash',
                onSelect = function()
                    lib.callback.await('LGF_OutfitBagOx.SyncRemoveBag', false, {bagID = idDui, ItemName = ItemName})
                    Bag:animAndCamClear(true)
                end
            }
        }
        lib.registerContext({
            id = ('bag_menu_%s'):format(idDui),
            title = locale('menu.bag_menu_title'),
            options = options,
            onExit = function()
                Bag:animAndCamClear(true)
            end
        })
        lib.showContext(('bag_menu_%s'):format(idDui))
    end
    function point:onEnter()
        if Config.interact == 'ox_target' then
            exports.ox_target:addLocalEntity(data.entity, {
                {
                    label = locale('interact.open_bag', data.bagID),
                    name = ('lgf_bag_%s'):format(data.bagID),
                    icon = 'fa-solid fa-suitcase',
                    distance = 1.5,
                    idBag = data.bagID,
                    canInteract = function(entity, distance, coords, name, bone)
                        return not bridge.DeatCheck(cache.ped)
                    end,
                    onSelect = function(data)
                        interactMenu(data.idBag)
                    end
                }
            })
        elseif Config.interact == 'LGF_SpriteTextUI' then
            data.duiHandlers[data.bagID] = exports.LGF_SpriteTextUI:HandleHoldTextUI(data.bagID, {
                Visible = true,
                Message = locale('interact.hold_to_open_bag', data.bagID),
                Bind = 'E',
                CircleColor = 'teal',
                UseOnlyBind = false,
                BindToHold = 38,
                TimeToHold = 0.5,
                DistanceHold = 2,
                Coords = self.coords,
                canInteract = function(id, distance)
                    return not bridge.DeatCheck(cache.ped)
                end,
                onCallback = function(idDui)
                    interactMenu(idDui)
                end
            })
        end
    end

    function point:onExit()
        if Config.interact == 'LGF_SpriteTextUI' then
            if data.duiHandlers[data.bagID] then
                exports.LGF_SpriteTextUI:CloseHoldTextUI(data.bagID)
                data.duiHandlers[data.bagID] = nil
            end
        end
        data.entity = nil
    end

    function point:nearby()
        if self.currentDistance < 3 and data.duiHandlers[data.bagID] and not lib.getOpenContextMenu() and not InputOpened and not IsInCode and not AlertOpened then
            if Config.interact == 'LGF_SpriteTextUI' then
                exports.LGF_SpriteTextUI:Draw3DSprite({
                    duiHandler = data.duiHandlers[data.bagID],
                    coords = vec3(self.coords.x, self.coords.y, self.coords.z - 0.4),
                    maxDistance = self.distance,
                })
            end
        end
    end
end)

function Bag:removeBag(bagID)
    local bagData = Bag.bags[bagID]
    if bagData then
        if bagData.point then
            bagData.point:remove()
        end
        if Config.interact == 'ox_target' then
            exports.ox_target:removeLocalEntity(bagData.entity, ('lgf_bag_%s'):format(bagID))
        elseif Config.interact == 'LGF_SpriteTextUI' then
            exports.LGF_SpriteTextUI:RemoveHoldTextUI(bagID)
        end
        if bagData.entity then
            DeleteEntity(bagData.entity)
        end
        Bag.bags[bagID] = nil
    else
        print(locale('interact.failed_remove_bag', bagID))
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for bagID, bagData in pairs(Bag.bags) do
            Bag:removeBag(bagID)
        end
    end
end)

RegisterNetEvent('LGF_OutfitBagOx.SyncRemoveBag', function(bagID)
    Bag:removeBag(bagID)
end)

exports('placeBag', function(data, slot)
    local itemName = data.name
    for _, bagConfig in ipairs(Config.BagData) do
        if bagConfig.itemName == itemName then
            local propName = bagConfig.propName
            local maxSlot = bagConfig.maxSlot
            exports.ox_inventory:useItem(data, function(itemData)
                if itemData then
                    local BagID = itemData.metadata and itemData.metadata.bagID or nil
                    Bag.modelProp = propName
                    Bag:PlaceBag(propName, maxSlot, itemName, BagID)
                end
            end)
            return
        end
    end
end)

local isLoaded = false

local function addLoadedInteraction()
    if isLoaded then return end
    local success = lib.callback.await('LGF_OutfitBagOx.triggerAllInteractions', false)
    if success then
        Wait(2000)
        isLoaded = true
    end
end

CreateThread(function()
    while true do
        Wait(100)
        if NetworkIsPlayerActive(PlayerId()) then
            addLoadedInteraction()
            break
        end
    end
end)
