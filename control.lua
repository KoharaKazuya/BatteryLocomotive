local key = require "utils.key"
local train = require "utils.train"
local receiver = require "utils.receiver"

script.on_init(function()
    global = {}
    global.entities = {}
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

local function remove_all_invalid_receivers()
    for i, e in pairs(global.entities) do
        if not (e and receiver.is_valid_receiver(global.entities, e.receiver)) then
            if e and e.receiver.valid then e.receiver.destroy() end
            global.entities[i] = nil
        end
    end
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
    defines.events.on_built_entity, defines.events.on_robot_built_entity
}, function(event) create_receiver(event.created_entity) end)

script.on_event({
    defines.events.on_entity_died, defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity
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

script.on_nth_tick(180, function()
    -- remove ghost receivers
    remove_all_invalid_receivers()
    for _, surface in pairs(game.surfaces) do
        local receivers = surface.find_entities_filtered {name = key.receiver}
        for _, r in pairs(receivers) do
            if not receiver.is_valid_receiver(global.entities, r) then
                receiver.destroy()
            end
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
