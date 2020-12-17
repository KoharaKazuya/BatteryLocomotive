local key = require "key"

local function all_locomotives(train)
    local locomotives = {}
    for _, l in pairs(train.locomotives.front_movers) do
        if l then table.insert(locomotives, l) end
    end
    for _, l in pairs(train.locomotives.back_movers) do
        if l then table.insert(locomotives, l) end
    end
    return locomotives
end

local function is_burning_battery_locomotive_fuel(locomotive)
    if not (locomotive.burner and locomotive.burner.currently_burning) then
        return false
    end

    local name = locomotive.burner.currently_burning.name
    return (name == key.fuel_coal) or (name == key.fuel_rocket) or
               (name == key.fuel_nuclear)
end

local function needed_energy(locomotive)
    if not is_burning_battery_locomotive_fuel(locomotive) then return 0 end

    return locomotive.burner.currently_burning.fuel_value -
               locomotive.burner.remaining_burning_fuel
end

local locomotive_fuel_map = {}
locomotive_fuel_map[key.locomotive] = key.fuel_coal
locomotive_fuel_map[key.locomotive_mk2] = key.fuel_rocket
locomotive_fuel_map[key.locomotive_mk3] = key.fuel_nuclear

local function set_currently_burning(locomotive)
    if locomotive.burner and not locomotive.burner.currently_burning then
        local fuel = locomotive_fuel_map[locomotive.name]
        if fuel then
            locomotive.burner.currently_burning = game.item_prototypes[fuel]
        end
    end
end

local function is_battery_locomotive(entity)
    if not entity then return false end
    local name = entity.name
    for _, v in pairs(global.locomotive_type_names) do
        if v == name then return true end
    end
    return false
end

return {
    all_locomotives = all_locomotives,
    needed_energy = needed_energy,
    set_currently_burning = set_currently_burning,
    is_battery_locomotive = is_battery_locomotive
}
