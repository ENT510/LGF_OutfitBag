if not IsDuplicityVersion() then
    function notify(title, message, type)
        lib.notify({
            title = title,
            description = message,
            type = type,
        })
    end
else
    function notify(source, data)
        lib.notify(source, {
            title = data.title,
            description = data.message,
            type = data.type,
        })
    end
end

return {
    notify = notify,
}
