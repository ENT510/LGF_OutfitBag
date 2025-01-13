local Shared = {}

function Shared.notify(title, message, position, type, source)
    if not IsDuplicityVersion() then
        lib.notify({
            title = title,
            description = message,
            type = type,
            duration = 5000,
            position = position or 'top',
        })
    else
        TriggerClientEvent('ox_lib:notify', source, {
            title = title,
            description = message,
            type = type,
            duration = 5000,
            position = position or 'top-right',
        })
    end
end

return Shared
