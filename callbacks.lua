-- support for callback conflicts in ammo's modules
-- assuming they are loaded by modules.lua or in the same manner

if input and ammo.db then
  function love.update(dt)
    ammo.update(dt)
    ammo.db.update(dt)
    input.update()
  end

  function love.keypressed(key, code)
    ammo.db.keypressed(key, code)
    input.keypressed(key)
  end

  function love.wheelmoved(dx, dy)
    ammo.db.wheelmoved(dx, dy)
    input.wheelmoved(dx, dy)
  end
elseif ammo.db then
  function love.update(dt)
    ammo.update(dt)
    ammo.db.update(dt)
  end
elseif input then
  function love.update(dt)
    ammo.update(dt)
    input.update()
  end
end

if ammo.db then
  function love.draw()
    ammo.draw()
    ammo.db.draw()
  end
end

love.resize = love.window.updateConstants
