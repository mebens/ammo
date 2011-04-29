--------------------------------
-- old stuff

local old = {
  mouseGetX = love.mouse.getX,
  mouseGetY = love.mouse.getY
}

--------------------------------
-- math

math.tau = math.pi * 2 -- the proper circle constant

function math.scale(v, min1, max1, min2, max2)
  return min2 + ((v - min1) / (max1 - min1)) * (max2 - min2)
end

function math.lerp(a, b, t)
  return a + (b - a) * t
end

function math.sign(x)
  return x > 0 and 1 or (x < 0 and -1 or 0)
end

function math.round(x)
  return math.floor(x + .5)
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

function math.angle(x1, y1, x2, y2)
  local a = math.atan2(y2 - y1, x2 - x1)
  return a < 0 and a + 360 or a
end

--------------------------------
-- table

function table.copy(t)
  local ret = {}
  for k, v in pairs(t) do ret[k] = v end
  return setmetatable(ret, getmetatable(t))
end

--------------------------------
-- love.audio

love.audio._sounds = {}

function love.audio._update()
  for _, v in pairs(love.audio._sounds) do
    for k, s in pairs(v._sources) do
      if s:isStopped() then
        table.remove(v._sources, k)
      end
    end
  end
end

--------------------------------
-- love.graphics

local _colorStack = {}

function love.graphics.pushColor(...)
  local r, g, b, a = love.graphics.getColor()
  _colorStack[#_colorStack + 1] = { r, g, b, a }
  love.graphics.setColor(...)
end

function love.graphics.popColor()
  love.graphics.setColor(table.remove(_colorStack))
end

--------------------------------
-- love.mouse

function love.mouse.getX()
  return old.mouseGetX() * camera.zoom + camera.x
end

function love.mouse.getY()
  return old.mouseGetY() * camera.zoom + camera.y
end

function love.mouse.getPosition()
  return love.mouse.getX(), love.mouse.getY()
end

--------------------------------
-- Object

function Object:applyAccessors()
  local mt = self.class._mt
  if not mt then return end
  local old = getmetatable(self)
  if mt.__index then old.__index = mt.__index end
  if mt.__newindex then old.__newindex = mt.__newindex end
end
