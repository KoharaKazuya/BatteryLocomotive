--- register a new locomotive type
-- @param name string of lomotive type name
local function register_locomotive_type(name)
    local contains = false
    for _, v in pairs(global.locomotive_type_names) do
        if v == name then contains = true end
    end
    if not (contains) then table.insert(global.locomotive_type_names, name) end
end

remote.add_interface("BatteryLocomotive",
                     {["register_locomotive_type"] = register_locomotive_type})
