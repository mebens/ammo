-- commands for manipulating the filesystem
local t = {}

local function getChar(s, i)
  return s:sub(i, i)
end

local function directorySort(x, y)
  local xdir = love.filesystem.getInfo(x).type == "directory"
  local ydir = love.filesystem.getInfo(y).type == "directory"

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
  local info = love.filesystem.getInfo(file)

  if not info then
    return "File does not exist."
  elseif info.type == "file" then
    return love.filesystem.read(file)
  else
    return "Path is not a file."
  end
end

function t:ls(arg1, arg2)
  local option = arg1 and arg1:match("%-(%w+)")
  local path = arg2
  if not arg2 and not option then path = arg1 end
  
  local files = love.filesystem.getDirectoryItems(path or ".")
  local all
  
  if option then
    all = option:match("a") ~= nil
    if option:match("d") ~= nil then table.sort(files, directorySort) end
  end
    
  for i, v in ipairs(files) do
    if all or getChar(v, 1) ~= "." then self.log(v) end
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
  local status = love.filesystem.write(path, self.joinWithSpaces(...))
  if not status then return "File wasn't written to." end
end

function t:rm(path)
  if love.filesystem.getInfo(path) then
    local status = love.filesystem.remove(path)
    if not status then return "File wasn't removed." end
  else
    return "File doesn't exist."
  end
end

function t:setidentity(name)
  love.filesystem.setIdentity(name)
end

function t:dofile(path)
  if love.filesystem.getInfo(path) then
    local func = love.filesystem.load(path)
    local status, result = pcall(func)
    return result
  else
    return "File doesn't exist."
  end
end

t.help = {
  cat = {
    args = "file",
    summary = "Prints a file to the console."
  },

  ls = {
    args = "[-opts] [dir]",
    summary = "Displays the contents of a directory.",
    description = [[If no directory is specified, the contents of the working directory are printed.
    
Options can specified in the form -ad, with either a or d present:
  - a: print all files (normally hidden files are excluded).
  - d: sort contents (alphabetical, directory first).]]
  },

  pwd = {
    summary = "Prints working directory."
  },

  psd = {
    summary = "Prints the save directory."
  },

  mkdir = {
    args = "path",
    summary = "Creates the specified directory."
  },

  mkfile = {
    args = "path [contents...]",
    summary = "Creates a file at the specified path and writes to it."
  },

  rm = {
    args = "path",
    summary = "Removes the file at the specified path."
  },

  setidentity = {
    args = "name",
    summary = "Sets the game's identity folder."
  },

  dofile = {
    args = "path",
    summary = "Runs the Lua file at the specified path."
  }
}

return t
