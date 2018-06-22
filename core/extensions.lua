-- table

function table.copy(t)
  local ret = {}
  for k, v in pairs(t) do ret[k] = v end
  return setmetatable(ret, getmetatable(t))
end

-- math

math.tau = math.pi * 2

-- locals for speed
local floor
local atan2
local sqrt

function math.scale(x, min1, max1, min2, max2)
  return min2 + ((x - min1) / (max1 - min1)) * (max2 - min2)
end

function math.lerp(a, b, t)
  return a + (b - a) * t
end

function math.sign(x)
  return x > 0 and 1 or (x < 0 and -1 or 0)
end

function math.round(x)
  return floor(x + .5)
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

function math.angle(x1, y1, x2, y2)
  local a = atan2(y2 - y1, x2 - x1)
  return a < 0 and a + math.tau or a
end

function math.len(x, y)
  return sqrt(x ^ 2 + y ^ 2)
end

function math.dist(x1, y1, x2, y2)
  return sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

function math.dot(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

-- love.graphics

local getColor = love.graphics.getColor
local setColor = love.graphics.setColor
local r, g, b, a = getColor()

function love.graphics.storeColor()
  r, g, b, a = getColor()
end

function love.graphics.resetColor()
  setColor(r, g, b, a)
end

-- love.window

local oldSetMode = love.window.setMode
local oldUpdateMode = love.window.updateMode

local function updateWindowConstants(w, h)
  if not w then
    w, h = love.graphics.getDimensions()
  end

  love.window.width, love.window.height = w, h
  love.graphics.width, love.graphics.height = w, h
end

function love.window.setMode(width, height, flags)
  local success, result = pcall(oldSetMode, width, height, flags)
  
  if success then
    if result then updateWindowConstants(width, height) end
    return result
  else
    error(result, 2)
    return false
  end
end

function love.window.updateMode(width, height, settings)
  local success, result = pcall(oldUpdateMode, width, height, settings)

  if success then
    if result then updateWindowConstants(width, height) end
    return result
  else
    error(result, 2)
    return false
  end
end

love.window.updateConstants = updateWindowConstants
updateWindowConstants()

-- love.mouse

love.mouse.getRawX = love.mouse.getX
love.mouse.getRawY = love.mouse.getY
love.mouse.getRawPosition = love.mouse.getPosition

-- for speed
local rawPos = love.mouse.getRawPosition

function love.mouse.getWorldX(camera)
  camera = camera or ammo.world.camera
  local x, y = camera:worldPosition(rawPos())
  return x
end

function love.mouse.getWorldY(camera)
  camera = camera or ammo.world.camera
  local x, y = camera:worldPosition(rawPos())
  return y
end

function love.mouse.getWorldPosition(camera)
  camera = camera or ammo.world.camera
  return camera:worldPosition(rawPos())
end

function love.mouse.switchToWorld()
  love.mouse.getX = love.mouse.getWorldX
  love.mouse.getY = love.mouse.getWorldY
  love.mouse.getPosition = love.mouse.getWorldPosition
end

function love.mouse.switchToRaw()
  love.mouse.getX = love.mouse.getRawX
  love.mouse.getY = love.mouse.getRawY
  love.mouse.getPosition = love.mouse.getRawPosition
end

love.mouse.switchToWorld()

-- backwards compatibility until 1.3
love.mouse.switchToRotated = love.mouse.switchToWorld
love.mouse.getRotatedX = love.mouse.getWorldX
love.mouse.getRotatedY = love.mouse.getWorldY
love.mouse.getRotatedPosition = love.mouse.getWorldPosition
