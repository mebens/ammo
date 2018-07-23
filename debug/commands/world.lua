-- commands for modifying the world
local t = {}

function t:pause()
  if ammo.world then ammo.world.active = not ammo.world.active end
end

function t:hide()
  if ammo.world then ammo.world.visible = not ammo.world.visible end
end

function t:step(steps)
  if not ammo.world then return end
  steps = steps and tonumber(steps) or 1

  for i = 1, steps do
    ammo.world:update(love.timer.getDelta())
  end
end

function t:backstep()
  if not ammo.world then return end
  steps = steps and tonumber(steps) or 1

  for i = 1, steps do
    ammo.world:update(-love.timer.getDelta())
  end
end

function t:recreate()
  if ammo.world then
    local world = ammo.world.class:new()
    world.active = ammo.world.active
    world.visible = ammo.world.visible
    ammo.world = world
  end
end

return t
