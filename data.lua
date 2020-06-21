local key = require "utils.key"

-- ### Technology ###

data:extend{
    {
        type = "technology",
        name = key.technology,
        icon = "__BatteryLocomotive__/graphics/technology/battery-locomotive.png",
        icon_size = 128,
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1}, {"logistic-science-pack", 1},
                {"chemical-science-pack", 1}
            },
            time = 30
        },
        prerequisites = {"railway", "electric-engine", "battery"},
        effects = {}
    }
}

-- ### Fuel Category ###

data:extend{{type = "fuel-category", name = key.fuel_category}}

-- ### Battery Locomotive + Fuel ###

local function add_locomotive(attr)
    -- entity
    local entity = table.deepcopy(data.raw["locomotive"]["locomotive"])
    entity.name = attr.locomotive
    entity.minable.result = attr.locomotive
    entity.color = {0.8, 0.8, 1}
    entity.burner = {
        effectivity = 1,
        fuel_inventory_size = 0,
        fuel_category = key.fuel_category
    }

    -- item
    local item = table.deepcopy(data.raw["item-with-entity-data"]["locomotive"])
    item.name = attr.locomotive
    item.order = item.order .. "-a[" .. attr.order .. "]"
    item.icon = "__BatteryLocomotive__/graphics/icons/battery-locomotive.png"
    item.place_result = attr.locomotive

    -- locomotive recipe
    local recipe = table.deepcopy(data.raw["recipe"]["locomotive"])
    recipe.name = attr.locomotive
    recipe.ingredients = attr.ingredients
    recipe.result = attr.locomotive

    -- fuel
    local fuel = table.deepcopy(data.raw["item"][attr.fuel_base])
    fuel.name = attr.fuel
    fuel.stack_size = 1
    fuel.flags = {"hidden"}
    fuel.fuel_category = key.fuel_category
    fuel.fuel_value = attr.fuel_value

    data:extend{entity, item, recipe, fuel}

    -- technology
    table.insert(data.raw["technology"][key.technology].effects,
                 {type = "unlock-recipe", recipe = attr.locomotive})
end

add_locomotive {
    locomotive = key.locomotive,
    order = key.locomotive .. "-mk1",
    fuel = key.fuel_coal,
    ingredients = {
        {name = "steel-plate", amount = 30},
        {name = "electronic-circuit", amount = 10},
        {name = "electric-engine-unit", amount = 20},
        {name = "battery", amount = 100}
    },
    fuel_base = "coal",
    fuel_value = "600MJ" -- Coal's fuel value (4MJ) * Coal's stack size (50) * Locomotive's fuel inventory size (3)
}
add_locomotive {
    locomotive = key.locomotive_mk2,
    order = key.locomotive_mk2,
    fuel = key.fuel_rocket,
    ingredients = {
        {name = key.locomotive, amount = 1}, {name = "battery", amount = 100},
        {name = "advanced-circuit", amount = 10}
    },
    fuel_base = "rocket-fuel",
    fuel_value = "1000MJ" -- Rocket fuel's fuel value (100MJ) * Rocket fuel's stack size (10) * Locomotive's fuel inventory size (3)
}
add_locomotive {
    locomotive = key.locomotive_mk3,
    order = key.locomotive_mk3,
    fuel = key.fuel_nuclear,
    ingredients = {
        {name = key.locomotive_mk2, amount = 1},
        {name = "battery", amount = 200},
        {name = "low-density-structure", amount = 10},
        {name = "processing-unit", amount = 30}
    },
    fuel_base = "nuclear-fuel",
    fuel_value = "3.63GJ" -- Nuclear fuel's fuel value (1.21GJ) * Nuclear fuel's stack size (1) * Locomotive's fuel inventory size (3)
}

-- ### Receiver ###

data:extend{
    {
        name = key.receiver,
        type = "electric-energy-interface",
        icon = "__BatteryLocomotive__/graphics/icons/battery-locomotive.png",
        icon_size = 64,
        icon_mipmaps = 4,
        collision_mask = {},
        energy_source = {
            type = "electric",
            buffer_capacity = "4MJ", -- Coal's fuel value
            usage_priority = "secondary-input"
        }
    }
}
