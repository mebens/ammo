-- table

function table.copy(t)
  local ret = {}
  for k, v in pairs(t) do ret[k] = v end
  return setmetatable(ret, getmetatable(t))
end

-- math

math.tau = math.pi * 2

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
  return math.floor(x + .5)
end

function math.clamp(x, min, max)
  return x < min and min or (x > max and max or x)
end

function math.angle(x1, y1, x2, y2)
  local a = math.atan2(y2 - y1, x2 - x1)
  return a < 0 and a + math.tau or a
end

function math.length(x, y)
  return math.sqrt(x ^ 2 + y ^ 2)
end

function math.distance(x1, y1, x2, y2)
  return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
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

local function setWindowConstants(w, h)
  if not w then
    w, h = love.graphics.getDimensions()
  end

  love.window.width, love.window.height = w, h
  love.graphics.width, love.graphics.height = w, h
end

function love.window.setMode(width, height, flags)
  local success, result = pcall(oldSetMode, width, height, flags)
  
  if success then
    if result then setWindowConstants(width, height) end
    return result
  else
    error(result, 2)
    return false
  end
end

function love.window.updateMode(width, height, settings)
  local success, result = pcall(oldUpdateMode, width, height, settings)

  if success then
    if result then setWindowConstants(width, height) end
    return result
  else
    error(result, 2)
    return false
  end
end

if not love.resize then
  love.resive = setWindowConstants
end

setWindowConstants()

-- love.mouse

love.mouse.getRawX = love.mouse.getX
love.mouse.getRawY = love.mouse.getY
love.mouse.getRawPosition = love.mouse.getPosition

-- for extra speed
local rawX = love.mouse.getRawX
local rawY = love.mouse.getRawY
local rawPos = love.mouse.getRawPosition

function love.mouse.getTranslatedX(camera)
  camera = camera or ammo.world.camera
  return (rawX() - love.graphics.width / 2) / camera.zoom + camera.x 
end

function love.mouse.getTranslatedY(camera)
  camera = camera or ammo.world.camera
  return (rawY() - love.graphics.height / 2) / camera.zoom + camera.y
end

function love.mouse.getTranslatedPosition(camera)
  camera = camera or ammo.world.camera
  local x, y = rawPos()
  return (x - love.graphics.width / 2) / camera.zoom + camera.x,
         (y - love.graphics.height / 2) / camera.zoom + camera.y
end

function love.mouse.getRotatedX(camera)
  camera = camera or ammo.world.camera
  local x, y = rawPos()
  local cos = math.cos(-camera.angle)
  local sin = math.sin(-camera.angle)
  x, y = (x - love.graphics.width / 2) / camera.zoom, (y - love.graphics.height / 2) / camera.zoom
  return (x * cos - y * sin) + camera.x
end

function love.mouse.getRotatedY(camera)
  camera = camera or ammo.world.camera
  local x, y = rawPos()
  local cos = math.cos(-camera.angle)
  local sin = math.sin(-camera.angle)
  x, y = (x - love.graphics.width / 2) / camera.zoom, (y - love.graphics.height / 2) / camera.zoom
  return (x * sin + y * cos) + camera.y
end

function love.mouse.getRotatedPosition(camera)
  camera = camera or ammo.world.camera
  local x, y = rawPos()
  local cos = math.cos(-camera.angle)
  local sin = math.sin(-camera.angle)
  x, y = (x - love.graphics.width / 2) / camera.zoom, (y - love.graphics.height / 2) / camera.zoom
  return (x * cos - y * sin) + camera.x, (x * sin + y * cos) + camera.y
end

function love.mouse.switchToWorld()
  love.mouse.positionMode = "world"
  love.mouse.getX = love.mouse.getWorldX
  love.mouse.getY = love.mouse.getWorldY
  love.mouse.getPosition = love.mouse.getWorldPosition
end

function love.mouse.switchToRotated()
  love.mouse.positionMode = "rotated"
  love.mouse.getX = love.mouse.getRotatedX
  love.mouse.getY = love.mouse.getRotatedY
  love.mouse.getPosition = love.mouse.getRotatedPosition
end

function love.mouse.switchToRaw()
  love.mouse.getX = love.mouse.getRawX
  love.mouse.getY = love.mouse.getRawY
  love.mouse.getPosition = love.mouse.getRawPosition
end

love.mouse.switchToWorld()
