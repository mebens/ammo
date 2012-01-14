-- IMPORTS --

require(ammo.path .. ".core.SpecialLinkedList")
require(ammo.path .. ".core.Vector")
require(ammo.path .. ".core.extensions")
require(ammo.path .. ".core.input")
require(ammo.path .. ".core.camera")
require(ammo.path .. ".core.World")
require(ammo.path .. ".core.Entity")
require(ammo.path .. ".core.Sound")

-- AMMO MODULE --

-- ammo is most likely defined the main init.lua
if not ammo then ammo = {} end

setmetatable(ammo, {
  __index = function(self, key) return rawget(self, '_' .. key) end,
  
  __newindex = function(self, key, value)
    if key == 'world' then
      self._goto = value
    else
      rawset(self, key, value)
    end
  end
})

function ammo.update(dt)
  -- update
  camera.update(dt)
  if ammo._world and ammo._world.active then ammo._world:update(dt) end
  love.audio._update()
  input._update()
  
  -- world switch
  if ammo._goto then
    if ammo._world and ammo._world.visible then ammo._world:stop() end
    ammo._world = ammo._goto
    ammo._goto = nil
    if ammo._world then ammo._world:start() end
  end
end

function ammo.draw()
  if ammo._world then ammo._world:draw() end
end

-- LOVE.RUN --

function love.run()
  if love.load then love.load(arg) end
  dt = 0

  -- Main loop time.
  while true do
    love.timer.step()
    dt = love.timer.getDelta()
    ammo.update(dt)
    if love.update then love.update(dt) end
    
    love.graphics.clear()
    ammo.draw()
    if love.draw then love.draw() end -- love.draw will be on-top of everything else

    -- Process events.
    for e, a, b, c in love.event.poll() do
      if e == "q" then
        if not love.quit or not love.quit() then
          if love.audio then love.audio.stop() end
          return
        end
      end
      
      input._event(e, a, b, c)
      love.handlers[e](a, b, c)
    end

    love.timer.sleep(1)
    love.graphics.present()
  end
end
