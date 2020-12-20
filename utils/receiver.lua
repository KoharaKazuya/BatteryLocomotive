local train = require "train"
local key = require "key"

local function is_receiver(entity)
    if not entity then return false end
    return entity.name == key.receiver
end

local function is_valid_receiver(global_pool, receiver)
    -- existence check
    local entity = nil
    for _, e in pairs(global_pool) do
        if e and e.receiver == receiver then entity = e end
    end
    if not entity then return false end

    -- valid
    if not (receiver.valid and entity.locomotive.valid) then return false end

    -- locomotive move
    if not (entity.locomotive.train and entity.locomotive.train.speed == 0) then
        return false
    end

    -- the same position
    if not (math.abs(receiver.position.x - entity.locomotive.position.x) < 0.5 and
        math.abs(receiver.position.y - entity.locomotive.position.y) < 0.5) then
        return false
    end

    return true
end

local function refuel(receiver, locomotive)
    if not locomotive.burner then return end

    local needed_energy = train.needed_energy(locomotive)
    local transfer_energy = math.min(needed_energy, receiver.energy)
    receiver.energy = receiver.energy - transfer_energy
    locomotive.burner.remaining_burning_fuel =
        locomotive.burner.remaining_burning_fuel + transfer_energy
end

return {
    is_receiver = is_receiver,
    is_valid_receiver = is_valid_receiver,
    refuel = refuel
}
