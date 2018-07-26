-- commands for modifying the debug module
local t = {}

local function info(self, f, title, graph, ...)
  local func, err = loadstring(self.joinWithSpaces(...))
  
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
    local conversion = tonumber(values[1])

    if conversion then
      t[key] = conversion
    else
      return "Invalid number"
    end
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
    if self.controls[val] ~= nil then
      return setValue(self.controls, val, ...)
    else
      return 'No control named "' .. val .. '"'
    end
  elseif self.settings[name] ~= nil then
    return setValue(self.settings, name, val, ...)
  else
    return 'No setting named "' .. name .. '"'
  end
end

function t:mkcmd(...)
  local args = { ... }
  local name = args[1]
  table.remove(args, 1)
  local func, err = loadstring(self.joinWithSpaces(unpack(args)))
  
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
    self.help[name] = nil
    return 'Command "' .. name .. '" has been removed.'
  else
    return 'No command named "' .. name .. '"'
  end
end

function t:addinfo(title, ...)
  return info(self, self.addInfo, title, false, ...)
end

function t:addgraph(title, ...)
  return info(self, self.addGraph, title, true, ...)
end

function t:rminfo(title)
  self.removeInfo(title)
end

t.rmgraph = t.rminfo

function t:silence()
  self.settings.silenceOutput = not self.settings.silenceOutput
end

t.help = {
  set = {
    args = "[control] name value ...",
    summary = "Set any setting or control for the debug console.",
    description = [[Set any setting in the debug console by specifying its name and value.
Set any keyboard control with the syntax "set control <name> <value>".

Values will be converted to a type based on their current value's type:
  - number: enter the value normally.
  - string: if the string contains a space, enclose with quotes.
  - boolean: enter "true" or "false".
  - table: enter each value separated by a space."]],
    example = "> set color 0.7 0.7 0.6 1\n> set control open q"
  },

  mkcmd = {
    args = "name code...",
    summary = "Create a command with Lua code.",
    example = "> mkcmd test self.log('test')"
  },

  rmcmd = {
    args = "name",
    summary = "Removes a command."
  },

  addinfo = {
    args = "title code...",
    summary = "Creates a new info item with Lua code.",
    example = "> addinfo Time return os.time()"
  },

  addgraph = {
    args = "title code...",
    summary = "Creates a new info/graph item with Lua code.",
    example = "> addgraph Rand return math.random(1, 1000)"
  },

  rminfo = {
    args = "title",
    summary = "Removes an info item with the specified title."
  },

  rmgraph = {
    args = "title",
    summary = "Removes an info item with the specified title."
  },

  silence = {
    summary = "Toggles silencing output from all following commands.",
    description = "Toggles silencing output from all following commands.\nShorthand for set silenceOutput true/false.\nOutput will still be printed to command line if printOutput is true."
  }
}

return t
