local input = {}
input.key = { down = { count = 0 } }
input.mouse = { down = { count = 0 } }
input.wheel = {}
input._maps = {}

local key = input.key
local mouse = input.mouse
local wheel = input.wheel

function input.define(t, ...)
  if type(t) == "string" then
    input._maps[t] = { key = { ... } }
  else
    if type(t.key) == "string" then t.key = { t.key } end
    if type(t.mouse) == "number" then t.mouse = { t.mouse } end
    input._maps[t[1]] = t
  end
end

function input.pressed(name)
  return input.check(name, "pressed")
end

function input.down(name)
  return input.check(name, "down")
end

function input.released(name)
  return input.check(name, "released")
end

function input.axisPressed(negative, positive)
  return input.checkAxis(negative, positive, "pressed")
end

function input.axisDown(negative, positive)
  return input.checkAxis(negative, positive, "down")
end

function input.axisReleased(negative, positive)
  return input.checkAxis(negative, positive, "released")
end

function input.check(name, type)
  local map = input._maps[name]
  
  if map.key then
    for _, v in pairs(map.key) do
      if input.key[type][v] then return true end
    end
  end
  
  if map.mouse then
    for _, v in pairs(map.mouse) do
      if input.mouse[type][v] then return true end
    end
  end
  
  if map.wheel and type ~= "released" and wheel[map.wheel] then return true end
  return false
end

function input.checkAxis(negative, positive, type)
  local axis = 0
  if input.check(negative, type) then axis = axis - 1 end
  if input.check(positive, type) then axis = axis + 1 end
  return axis
end

function input.update()
  key.pressed = { count = 0 }
  key.released = { count = 0 }
  mouse.pressed = { count = 0 }
  mouse.released = { count = 0 }
  for key, _ in pairs(wheel) do wheel[key] = nil end
  mouse.x = love.mouse.getX()
  mouse.y = love.mouse.getY()
end

function input.keypressed(k)
  key.pressed[k] = true
  key.down[k] = true
  key.pressed.count = key.pressed.count + 1
  key.down.count = key.down.count + 1
end

function input.keyreleased(k)
  key.released[k] = true
  key.down[k] = nil
  key.released.count = key.released.count + 1
  key.down.count = key.down.count - 1
end

function input.mousepressed(x, y, button)
  mouse.pressed[button] = true
  mouse.down[button] = true
  mouse.pressed.count = mouse.pressed.count + 1
  mouse.down.count = mouse.down.count + 1
end

function input.mousereleased(x, y, button)
  mouse.released[button] = true
  mouse.down[button] = nil
  mouse.released.count = mouse.released.count + 1
  mouse.down.count = mouse.down.count - 1
end

function input.wheelmoved(x, y)
  if x < 0 then wheel.left = true end
  if x > 0 then wheel.right = true end
  if y > 0 then wheel.up = true end
  if y < 0 then wheel.down = true end
end

input.update()

if not love.keypressed then love.keypressed = input.keypressed end
if not love.keyreleased then love.keyreleased = input.keyreleased end
if not love.mousepressed then love.mousepressed = input.mousepressed end
if not love.mousereleased then love.mousereleased = input.mousereleased end
if not love.wheelmoved then love.wheelmoved = input.wheelmoved end

return input
