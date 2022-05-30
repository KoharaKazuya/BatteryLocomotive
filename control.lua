require "remote-interface"

local key = require "utils.key"
local train = require "utils.train"
local receiver = require "utils.receiver"

local remove_all_invalid_receivers

local function mod_compatibility_hooks()
	if remote.interfaces["FuelTrainStop"] then
		remote.call("FuelTrainStop", "exclude_from_fuel_schedule", key.locomotive)
		remote.call("FuelTrainStop", "exclude_from_fuel_schedule", key.locomotive_mk2)
		remote.call("FuelTrainStop", "exclude_from_fuel_schedule", key.locomotive_mk3)
	end
end

script.on_init(function()
    global = {}
    global.entities = {}
    global.locomotive_type_names = {
        [key.locomotive] = true,
        [key.locomotive_mk2] = true,
        [key.locomotive_mk3] = true
    }
    global.schema_version = 2
    mod_compatibility_hooks()
end)

script.on_load(function()
    mod_compatibility_hooks()
end)

script.on_configuration_changed(function(data)
    -- migrate global table
    local version = global.schema_version or 1
    if version < 2 then
        global.locomotive_type_names = {
            [key.locomotive] = true,
            [key.locomotive_mk2] = true,
            [key.locomotive_mk3] = true
        }
    end
    global.schema_version = 2
    -- cleanup
    remove_all_invalid_receivers()
end)

local function create_receiver(locomotive)
    if not train.is_battery_locomotive(locomotive) then return end

    local r = locomotive.surface.create_entity {
        name = key.receiver,
        position = locomotive.position,
        force = "player"
    }
    train.set_currently_burning(locomotive)
    if train.needed_energy(locomotive) < r.electric_buffer_size then
        r.destroy()
    else
        table.insert(global.entities, {receiver = r, locomotive = locomotive})
    end
end

remove_all_invalid_receivers = function()
    for i, e in pairs(global.entities) do
        if not (e and receiver.is_valid_receiver(global.entities, e.receiver)) then
            if e and e.receiver.valid then e.receiver.destroy() end
            global.entities[i] = nil
        end
    end
end

local function remove_uncontrolled_receiver(entity)
    if not receiver.is_receiver(entity) then return end
    if receiver.is_valid_receiver(global.entities, entity) then return end
    entity.destroy()
end

script.on_event(defines.events.on_train_changed_state, function(event)
    if event.train.speed == 0 then
        --- create hidden receiver over locomotive when the train stopped
        local locomotives = train.all_locomotives(event.train)
        for _, locomotive in pairs(locomotives) do
            create_receiver(locomotive)
        end
    else
        -- remove receivers when the train left
        remove_all_invalid_receivers()
    end
end)

script.on_event({
    defines.events.on_built_entity, defines.events.on_robot_built_entity,
    defines.events.script_raised_built, defines.events.on_entity_cloned
}, function(event)
    local entity = event.created_entity or event.entity or event.destination
    create_receiver(entity)
    remove_uncontrolled_receiver(entity)
end)

script.on_event({
    defines.events.on_entity_died, defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity, defines.events.script_raised_destroy
}, function(event)
    local entity = event.entity
    if not train.is_battery_locomotive(entity) then return end

    -- remove receivers when the train left
    for i, e in pairs(global.entities) do
        if e and e.locomotive == entity then
            if e and e.receiver.valid then e.receiver.destroy() end
            global.entities[i] = nil
        end
    end
end)

-- receivers feed battery locomotives on every tick
script.on_event(defines.events.on_tick, function()
    for i, e in pairs(global.entities) do
        if e and receiver.is_valid_receiver(global.entities, e.receiver) then
            train.set_currently_burning(e.locomotive)
            receiver.refuel(e.receiver, e.locomotive)
            -- remove receiver if it doesn't need refuel
            if train.needed_energy(e.locomotive) <
                e.receiver.electric_buffer_size then
                e.receiver.destroy()
                global.entities[i] = nil
            end
        end
    end
end)
