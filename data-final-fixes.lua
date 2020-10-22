local key = require "utils.key"

local function sync_entity_perf(entity_key)
    local entity = data.raw["locomotive"][entity_key]
    local base = data.raw["locomotive"]["locomotive"]

    entity.braking_power = base.braking_power
    entity.braking_force = base.braking_force
    entity.weight = base.weight
    entity.max_speed = base.max_speed
    entity.max_power = base.max_power
end

sync_entity_perf(key.locomotive)
sync_entity_perf(key.locomotive_mk2)
sync_entity_perf(key.locomotive_mk3)

local function energy_multiply(energy, a, b)
    local s, e = string.find(energy, "^%d+")
    local amount = string.sub(energy, s, e)
    local unit = string.sub(energy, e + 1)
    return (tonumber(amount) * a * b) .. unit
end

local inventory_size = math.max(1, data.raw["locomotive"]["locomotive"].burner
                                    .fuel_inventory_size)

local function sync_fuel_perf(fuel_key, base_key)
    local fuel = data.raw.item[fuel_key]
    local base = data.raw.item[base_key]

    fuel.fuel_value = energy_multiply(base.fuel_value, base.stack_size,
                                      inventory_size)
    fuel.fuel_acceleration_multiplier = base.fuel_acceleration_multiplier
    fuel.fuel_top_speed_multiplier = base.fuel_top_speed_multiplier
end

sync_fuel_perf(key.fuel_coal, "coal")
sync_fuel_perf(key.fuel_rocket, "rocket-fuel")
sync_fuel_perf(key.fuel_nuclear, "nuclear-fuel")
