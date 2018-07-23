-- commands for modifying the debug module
local t = {}

local function info(self, f, title, graph, ...)
  local func, err = loadstring(self._joinWithSpaces(...))
  
  if err then
    return err
  else
    f(title, func)
  end
end

local function setValue(t, key, ...)
  local base = t[key]
  local values = { ... }
  
  if type(base) == "number" then
    t[key] = tonumber(values[1])
  elseif type(base) == "boolean" then
    t[key] = values[1] == "true"
  elseif type(base) == "table" then
    for i, v in ipairs(values) do setValue(t[key], i, v) end
  elseif type(base) == "string" then
    t[key] = values[1] == nil and "" or tostring(values[1])
  end
end

function t:set(name, val, ...)
  if name == "control" then
    if self.controls[val] then
      setValue(self.controls, val, ...)
    else
      return 'No control named "' .. val .. '"'
    end
  elseif self.settings[name] then
    setValue(self.settings, name, val, ...)
  else
    return 'No setting named "' .. name .. '"'
  end
end

function t:mkcmd(...)
  local args = { ... }
  local name = args[1]
  table.remove(args, 1)
  local func, err = loadstring(self._joinWithSpaces(unpack(args)))
  
  if err then
    return err
  else
    local msg = 'Command "' .. name .. '" has been ' .. (self.commands[name] and "replaced." or "added.")
    self.commands[name] = func
    return msg
  end
end

function t:rmcmd(name)
  if self.commands[name] then
    self.commands[name] = nil
    return 'Command "' .. name .. '" has been removed.'
  else
    return 'No command named "' .. name .. '"'
  end
end

function t:addinfo(title, ...)
  info(self, self.addInfo, title, false, ...)
end

function t:addgraph(title, ...)
  info(self, self.addGraph, title, true, ...)
end

function t:rminfo(title)
  self.removeInfo(title)
end

t.rmgraph = t.rminfo

return t
