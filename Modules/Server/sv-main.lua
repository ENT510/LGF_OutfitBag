local Shared = require "Modules.Shared.shared"
Bags = {}


lib.callback.register("LGF_OutfitBagOx.syncInteraction", function(source, data)
    TriggerClientEvent("LGF_OutfitBagOx.syncInteraction", -1, data)
    local itemName = data.itemName
    local bagID = data.bagID

    Bags[data.bagID] = data

    if source then
        local success, response = exports.ox_inventory:RemoveItem(source, itemName, 1)

        if not success then
            print(("Failed to remove item with bagID %s: %s"):format(bagID, response))
        end
    end
end)


lib.callback.register("LGF_OutfitBagOx.SyncRemoveBag", function(source, data)
    local src = source
    if not src then return end

    if Bags[data.bagID] then
        local success, resp = exports.ox_inventory:AddItem(source, data.ItemName, 1, {
            bagID = data.bagID,
            description = ("Bag %s"):format(data.bagID)
        })

        TriggerClientEvent("LGF_OutfitBagOx.SyncRemoveBag", -1, data.bagID)

        Bags[data.bagID] = nil
        return success, resp
    end
end)


lib.callback.register("LGF_OutfitBagOx.saveCurrentOutfit", function(source, Skin, bagID, OutfitName, Slot)
    local outfitName = OutfitName
    local uniqueCode

    repeat
        uniqueCode = Functions.generateUniqueCode()
    until not Functions.codeExists(uniqueCode)


    local outfitData = json.encode(Skin)
    local query = 'INSERT INTO lgf_outfitbag (outfit_name, outfit_data, bag_id, outfit_code) VALUES (?, ?, ?, ?)'
    local parameters = { outfitName, outfitData, bagID, uniqueCode }


    local result = MySQL.query.await(query, parameters)


    if result then
        Shared.notify("Outfit Saved",
            ("Your outfit has been successfully saved with the unique code: %s "):format(uniqueCode), "top-right",
            "success", source)
        return uniqueCode
    else
        return nil
    end
end)


lib.callback.register("LGF_OutfitBagOx.getOutfitFromId", function(source, bagID)
    return Functions.getOutfits(bagID)
end)


lib.callback.register("LGF_OutfitBagOx.addOutfitByCode", function(source, data)
    local query = 'SELECT * FROM lgf_outfitbag WHERE outfit_code = ?'
    local result = MySQL.query.await(query, { data.codeName })


    if not result or #result == 0 then
        Shared.notify("Outfit Not Found", ("The outfit code %s is not valid."):format(data.outfit_code), "top-right",
            "error", source)
        return nil
    end


    local outfit = result[1]
    local outfitData = json.decode(outfit.outfit_data)

    local insertQuery = 'INSERT INTO lgf_outfitbag (outfit_name, outfit_data, bag_id, outfit_code) VALUES (?, ?, ?, ?)'
    local insertParams = { outfit.outfit_name, json.encode(outfitData), data.bagIDToAdd, outfit.outfit_code }


    local insertResult = MySQL.insert.await(insertQuery, insertParams)


    if insertResult then
        Shared.notify("Outfit Added",
            ("The outfit with code %s was successfully added to your bag."):format(data.outfit_code), "top-right",
            "success", source)
        return {
            outfit_name = outfit.outfit_name,
            outfit_data = outfitData,
            outfit_code = outfit.outfit_code
        }
    end
end)


lib.callback.register("LGF_OutfitBagOx.deleteOutfit", function(source, data)
    Functions.deleteOutfitFromId(source, data)
end)

lib.callback.register("LGF_OutfitBagOx.triggerAllInteractions", function(source)
    for bagID, data in pairs(Bags) do
        TriggerClientEvent("LGF_OutfitBagOx.syncInteraction", source, data)
    end
    return true
end)


local table_exist = MySQL.query.await('SHOW TABLES LIKE ?', { 'lgf_outfitbag' })
if #table_exist > 0 then return end

MySQL.query([[
    CREATE TABLE IF NOT EXISTS `lgf_outfitbag` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `outfit_name` varchar(255) DEFAULT NULL,
        `outfit_data` longtext DEFAULT NULL,
        `bag_id` int(11) DEFAULT NULL,
        `outfit_code` text DEFAULT NULL,
        PRIMARY KEY (`id`)
    ) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
]])
