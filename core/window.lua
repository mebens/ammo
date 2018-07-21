-- window constants

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
