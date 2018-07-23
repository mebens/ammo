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

function t:backstep(steps)
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

t.help = {
  pause = {
    summary = "Pauses/unpauses the current world."
  },

  hide = {
    summary = "Hides/unhides the current world."
  },

  step = {
    args = "[count]",
    summary = "Steps the world forward one or more frames.",
    description = "Calls the current world's update function with the current delta time, one or more times (if specified)."
  },

  backstep = {
    args = "[count]",
    summary = "Steps the world backward one or more frames.",
    description = "Calls the current world's update function with the negative of the current delta time, one or more times (if specified)."
  },

  recreate = {
    summary = "Replaces the current world with a new instance of itself."
  }
}

return t
