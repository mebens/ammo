-- X MODULE --

-- x is most likely defined by init.lua
if not x then x = {} end

setmetatable(x, {
  __index = function(self, key) return rawget(self, '_' .. key) end,
  
  __newindex = function(self, key, value)
    if key == 'world' then
      self._goto = value
    else
      rawset(self, key, value)
    end
  end
})

function x.update(dt)
  -- update
  camera.update(dt)
  if x._world then x._world:update(dt) end
  love.audio._update()
  input._update()
  
  -- world switch
  if x._goto then
    if x._world then x._world:stop() end
    x._world = x._goto
    x._goto = nil
    if x._world then x._world:start() end
  end
end

function x.draw()
  if x._world then x._world:draw() end
end

-- LOVE.RUN --

function love.run()
  if love.load then love.load(arg) end
  dt = 0

  -- Main loop time.
  while true do
    love.timer.step()
    dt = love.timer.getDelta()
    x.update(dt)
    if love.update then love.update(dt) end
    
    love.graphics.clear()
    x.draw()
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

