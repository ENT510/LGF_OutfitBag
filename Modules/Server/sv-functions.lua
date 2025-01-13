local Shared = require "Modules.Shared.shared"
Functions = {}

function Functions.getOutfits(bagID)
    if not bagID then
        return {}
    end

    local query = 'SELECT * FROM lgf_outfitbag WHERE bag_id = ?'
    local result = MySQL.query.await(query, { bagID })

    if not result or #result == 0 then
        return {}
    end

    local outfits = {}
    for _, row in ipairs(result) do
        outfits[#outfits + 1] = {
            outfit_name = row.outfit_name,
            outfit_data = json.decode(row.outfit_data),
            outfit_code = row.outfit_code
        }
    end

    return outfits
end

function Functions.deleteOutfitFromId(source, data)
    local query = 'DELETE FROM lgf_outfitbag WHERE outfit_code = ? AND bag_id = ?'
    local result = MySQL.query.await(query, { data.outfit_code, data.bagID })

    if result then
        Shared.notify("Outfit Deleted", "The outfit has been successfully deleted.", "top-right", "success", source)
    else
        Shared.notify("Error", "There was an error deleting the outfit.", "top-right", "error", source)
    end
end

function Functions.generateUniqueCode()
    local code = ("%s%s"):format("#", lib.string.random("A0A0A0", 5))
    return code
end

function Functions.codeExists(code)
    local query = 'SELECT COUNT(*) as count FROM lgf_outfitbag WHERE outfit_code = ?'
    local result = MySQL.query.await(query, { code })

    return result[1].count > 0
end
