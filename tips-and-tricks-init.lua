-- map
game.camera_zoom = 1
game.surfaces[1].create_entities_from_blueprint_string {
    string = "0eNqdmOuO2jAQhd/FvxMpvuX2KhVaBTDUUnCQ46xKEe9eZ6HZJbjaM+UPBOJvRj4cz1GubNtP5uytC6y9Mrsb3MjaH1c22qPr+vm7cDkb1jIbzIllzHWn+cp3tme3jFm3N79Yy2+bjBkXbLDmvv7j4vLmptPW+HjDsjLEpS4fw3COtPMwxiWDm+tETF5VGbvEd60je2+92d1/LTM2hu7+mYXOH03Ieaz/UkcsdXaTfzf7/KPR10K1eBQSq0IJplyY49z88Wf4F3VpXz5TRYKqcKrGqRqnSpxa4lSOUyuYWjY4tcapBLUanEpQixc4liAX5ziWoBcXMFYTBOO4vzRBMY4bTFMkwx2mKZLhFtMUyXCPKYpkuMkURTLcZYogmSjAoaCK9FCQKSjusfrRq2qesVUK++kx08cbvd3lxhl/vORxRBt/6HYmZeO/nRer7cjYdjocjH8b7W8zHzjLK1X804lbe8yXBs5Dnyqq6y9FnYlbsB0mP49/0WxSeNyRskpvGU9hNTrzH/2qEoCWIFSqBZrCVMTeZP3cm0pBa2Jva6hOQZv/0l6WL9rLlPayINtF6u+7lpyY96T43oNSEM+LNTR1CElJ/vOvNyB1DElFDqeSA91qcjqFsCU5nkLYipxPIWxNDqgQtiEnVASrCnJEhbCcHFEhrCBHVAgryREVwipyRIWwmhxRIWxJjqgQtiJHVAhbkyMqhG3IERXB6oIcUV+xm+z+NKX98vAlY+/Gj/cbaq6qRlSiKHQZZ8vtD+0gvXQ=",
    position = {0, -12}
}

-- player
player = game.create_test_player {name = "kovarex"}
player.teleport({0, 4.5})
game.camera_player = player
game.camera_player_cursor_position = player.position

step_1 = function()
    -- place locomotive
    player.cursor_stack.set_stack {name = "battery-locomotive"}
    game.camera_player_cursor_direction = defines.direction.east
    script.on_nth_tick(1, function()
        if game.move_cursor {position = {2.5, 1.5}} then
            wait_and_run(10, step_2)
        end
    end)
end

step_2 = function()
    -- build
    player.build_from_cursor {
        position = game.camera_player_cursor_position,
        direction = 2
    }
    locomotive = game.surfaces[1].find_entities_filtered{
        name = "battery-locomotive"
    }[1]

    wait_and_run(30, step_3)
end

step_3 = function()
    -- place electric-pole
    player.cursor_stack.set_stack {name = "small-electric-pole"}
    game.camera_player_cursor_direction = defines.direction.east
    script.on_nth_tick(1, function()
        if game.move_cursor {position = {2.5, -0.5}} then
            wait_and_run(10, step_4)
        end
    end)
end

step_4 = function()
    -- build
    player.build_from_cursor {
        position = game.camera_player_cursor_position,
        direction = 2
    }
    -- refuel
    locomotive.burner.currently_burning =
        game.item_prototypes["battery-locomotive-hidden-locomotive-fuel-nuclear"]
    locomotive.burner.remaining_burning_fuel = 1000000

    wait_and_run(30, step_5)
end

step_5 = function()
    -- launch train
    locomotive.train.schedule = {
        current = 1,
        records = {{station = "target-1", wait_conditions = {}}}
    }
    locomotive.train.manual_mode = false

    wait_and_run(90, reset)
end

reset = function()
    locomotive.destroy()
    pole =
        game.surfaces[1].find_entities_filtered{name = "small-electric-pole"}[1]
    pole.destroy()
    game.camera_player_cursor_position = player.position

    wait_and_run(30, step_1)
end

wait_and_run = function(wait_count, f)
    script.on_nth_tick(1, function()
        if wait_count > 0 then
            wait_count = wait_count - 1
            return
        end
        f()
    end)
end

-- start
wait_and_run(30, step_1)
