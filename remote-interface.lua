--- register a new locomotive type
-- @param name string of lomotive type name
local function register_locomotive_type(name)
    global.locomotive_type_names[name] = true
end

remote.add_interface("BatteryLocomotive",
                     {["register_locomotive_type"] = register_locomotive_type})
