-- commands for manipulating the filesystem
local t = {}

local function getChar(s, i)
  return s:sub(i, i)
end

local function directorySort(x, y)
  local xdir = love.filesystem.isDirectory(x)
  local ydir = love.filesystem.isDirectory(y)
    
  if xdir and not ydir then
    return true
  elseif ydir and not xdir then
    return false
  else
    local cx, cy
    
    -- simple alphanumerical sort
    for i = 1, math.min(#x, #y) do
      cx = getChar(x, i)
      cy = getChar(y, i) 
      if cx ~= cy then return cx < cy end
    end
    
    return true
  end
end

function t:cat(file)
  if love.filesystem.isFile(file) then
    return love.filesystem.read(file)
  else
    return "Either the file doesn't exist or the path specifies a directory."
  end
end

function t:ls(arg1, arg2)
  local option = arg1 and arg1:match("%-(%w+)")
  local path = arg2
  if not arg2 and not option then path = arg1 end
  
  local files = love.filesystem.enumerate(path or ".")
  local all
  
  if option then
    all = option:match("a") ~= nil
    if option:match("d") ~= nil then table.sort(files, directorySort) end
  end
    
  for i, v in ipairs(files) do
    if getChar(v, 1) ~= "." or all then self.log(v) end
  end
end

function t:pwd()
  return love.filesystem.getWorkingDirectory()
end

function t:psd()
  return love.filesystem.getSaveDirectory()
end

function t:mkdir(path)
  local status = love.filesystem.mkdir(path)
  if not status then return "Directory wasn't created." end
end

function t:mkfile(path, ...)
  local status = love.filesystem.write(path, self._joinWithSpaces(...))
  if not status then return "File wasn't written to." end
end

function t:rm(file)
  if love.filesystem.exists(file) then
    local status = love.filesystem.remove(file)
    if not status then return "File wasn't removed." end
  else
    return "File doesn't exist."
  end
end

function t:setidentity(name)
  love.filesystem.setIdentity(name)
end

function t:dofile(file)
  if love.filesystem.exists(file) then
    local func = love.filesystem.load(file)
    local status, result = pcall(func)
    return result
  else
    return "File doesn't exist."
  end
end

return t
