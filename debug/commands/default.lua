local t = {}

local function sortedKeys(t)
  local keys = {}
  local n = 1

  for k, _ in pairs(t) do
    keys[n] = k
    n = n + 1
  end

  table.sort(keys)
  return keys
end

function t:lua(...)
  local func, err = loadstring(self.joinWithSpaces(...))
  
  if err then
    return err
  else
    local result, msg = pcall(func)
    return msg
  end
end

-- works like the Lua interpreter
t["="] = function(self, ...)
  return self.commands.lua(self, "return", ...)
end

function t:bat(file)
  if love.filesystem.getInfo(file) then
    self.runBatch(file)
  else
    return "File doesn't exist."
  end
end

function t:include(...)
  local args = { ... }

  if #args > 0 then
    for _, v in ipairs(args) do
      self.include(v)
    end
  else
    self.includeAll()
  end
end

function t:exclude(...)
  for _, v in ipairs{...} do
    self.exclude(v)
  end
end

t["repeat"] = function(self, times, ...)
  local cmd = self.joinWithSpaces(...)
  for i = 1, tonumber(times) do self.runCommand(cmd) end
end

function t:clear()
  self.clear()
end

function t:echo(...)
  return self.joinWithSpaces(...)
end

function t:reset()
  if not self.resetInProgress then self.reset() end
end

function t:reload(path)
  return self.reload(path)
end

function t:info()
  self.settings.alwaysShowInfo = not self.settings.alwaysShowInfo
end

function t:graphs()
  self.settings.drawGraphs = not self.settings.drawGraphs
end

function t:help(cmd)
  if not cmd then
    local names = sortedKeys(self.commands)

    for _, name in pairs(names) do
      local str = "* " .. name
      local docs = self.help[name]
      
      if docs then
        if docs.args then str = str .. " " .. docs.args end
        if docs.summary then str = str .. " -- " .. docs.summary end
      end
      
      self.log(str)
    end
  elseif self.commands[cmd] then
    local docs = self.help[cmd]
    
    if docs then
      local str = "SYNTAX\n" .. cmd
      if docs.args then str = str .. " " .. docs.args end
      if docs.summary then str = str .. "\n \nSUMMARY\n" .. docs.summary end
      if docs.description then str = str .. "\n \nDESCRIPTION\n" .. docs.description end
      if docs.example then str = str .. "\n \nEXAMPLE\n" .. docs.example end
      return str
    else
      return 'No documentation for "' .. cmd .. '"'
    end
  else
    return 'No command named "' .. cmd .. '"'
  end
end

function t:controls()
  local names = sortedKeys(self.controls)

  for _, name in ipairs(names) do
    local key = self.controls[name]

    if key and key ~= "" then
      self.log(name .. ": " .. key)
    end
  end
end

-- COMMAND DOCUMENTATION --

-- need to use alternate name because of help command
t._help = {
  lua = {
    args = "code...",
    summary = "Compiles and executes Lua code. Returns the result.",
    example = "> lua function globalFunc() return 3 ^ 2 end\n> lua return globalFunc()\n9"
  },
  
  ["="] = {
    args = "code...",
    summary = "Executes Lua code, but also prefixes the return statement to the code.",
    description = "Compiles and executes Lua code, much like the lua command.\nHowever, it prefixes the return statement to the code.\nA space between this command and its arguments is optional.",
    example = "> =3 + 4\n7"
  },
  
  bat = {
    args = "file",
    summary = "Executes a batch file containing multiple commands.",
    description = "Executes a batch file. A batch file is a text which contains multiple commands which can be executed on the console."
  },

  include = {
    args = "[module]...",
    summary = "Include one or more of the bundled command modules.",
    description = "Include one or more of the command modules contained in debug/commands by specifying their names (no .lua extension). Include all of them by omitting the argument."
  },

  exclude = {
    args = "module...",
    summary = "Remove one or more of the bundled command modules.",
    description = "Remove one or more of the command modules contained in debug/commands by specifying their names (no .lua extension)."
  },
  
  ["repeat"] = {
    args = "num-times command [args...]",
    summary = "Repeats a command multiple times.",
    example = "> repeat 3 echo hello\nhello\nhello\nhello"
  },
  
  clear = {
    summary = "Clears the console's text buffer."
  },

  reset = {
    summary = "Reset the console, running the initial batch file if present."
  },

  reload = {
    args = "package-path",
    summary = "Attempts to reload the given file.",
    description = "Attempts to reload the given file, searching for it in all Lua's package paths. Dots (from a package path) and backslashes are converted to forward slashes before checking."
  },
  
  echo = {
    args = "text...",
    summary = "Outputs the text given.",
    example = "> echo foo bar \"la la\"\nfoo bar la la"
  },

  info = {
    summary = "Toggles whether info is shown when console is closed."
  },

  graphs = {
    summary = "Toggles the display of any active graphs."
  },
  
  help = {
    args = "[command]",
    summary = "Lists all available commands or provides documentation for a specific command."
  },

  controls = {
    summary = "Lists all currently assigned keyboard controls for the console."
  }
}

return t
