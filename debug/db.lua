local db = {}
db.path = ({...})[1]:gsub("%.db$", "")
local Info = require(db.path .. ".Info")

-- PROPERTIES/SETTINGS --

db.y = -1000
db.opened = false
db.active = false
db.visible = false
db.live = false
db.resetInProgress = false -- flag to prevent infinite reset loop

db.input = ""
db.history = { index = 0 }
db.buffer = { index = 0 }
db.info = {}
db.commands = {}

-- LOCAL --

-- a few timer variables
local timers = {
  multiErase = 0,
  multiEraseChar = 0,
  blink = 0 -- negative = cursor off, positive = cursor on
}

local rejectInput = false -- used to not receive open control as text input
local modified = {} -- holds modified times for included files

-- removes the last character from the input line
local function removeCharacter()
  db.input = db.input:sub(1, #db.input - 1)
end

-- adds the item to the table, making sure the table's length hasn't exceeded the limit
local function addTo(t, v, limit)
  t[#t + 1] = v
  if #t > limit then table.remove(t, 1) end
  t.index = #t
end

-- adds the text to the buffer, making sure to split it into separate lines
local function addToBuffer(str)
  for line in str:gmatch("[^\n]+") do
    addTo(db.buffer, line, db.settings.bufferLimit)
  end
end

-- compile an argument as a string if possible
local function compileArg(arg)
  if arg:sub(1, 1) == "$" then
    arg = db.runCommand(arg:match("^$(.+)$$"), true)
  else  
    local func = loadstring("return " .. arg)
    
    if func then
      arg = func()
    else
      db.log("Couldn't compile argument #" .. (index - 1) .. " as string.")
    end
  end
  
  return arg
end

-- converts package path to file path and finds it in any given package path
local function convertPath(path)
  path = path:gsub("[%.\\]", "/") -- converts backslash for windows compatibility
  
  for p in package.path:gmatch("[^;]+") do
    local x = p:gsub("\\", "/"):gsub("%?", path):gsub("^%./", "")
    if love.filesystem.getInfo(x) then return x end
  end
end

-- both these are used by the tween in moveConsole
local function openEnd()
  db.active = true
end

local function closeEnd()
  db.visible = false
end

-- change the console's position depending on db.opened
local function moveConsole(doTween)
  local y = db.opened and 0 or -db.settings.height - db.settings.borderSize
  if doTween == nil then doTween = true end
  
  if doTween and ammo.ext.tweens then
    db.tween = Tween:new(db, db.settings.openTime, { y = y }, nil, db.opened and openEnd or closeEnd)
    db.tween:start()
    
    if db.opened then
      db.visible = true
    else
      db.active = false
    end
  else
    db.y = y
    db.active = db.opened
    db.visible = db.opened
  end
end

-- handles the execution of the current input line
local function handleInput()
  addToBuffer(db.settings.prompt .. db.input)
  db.runCommand(db.input)
  addTo(db.history, db.input, db.settings.bufferLimit)
  db.history.index = #db.history + 1  
  db.input = ""
end

-- displays the currently selected line in the history
local function handleHistory()
  local i = db.history.index
  if #db.history == 0 then return end
  
  if i == #db.history + 1 then
    db.input = ""
  else
    db.input = db.history[i]
  end
end

-- FUNCTIONS --

function db.init()
  db.y = -db.settings.height
  db.reset(true)
  if db.live then db.check() end
end

function db.resetSettings()
  local initFile = "db-init"

  -- init file should be preserved across resets
  if db.settings and db.settings.initFile then
    initFile = db.settings.initFile
  end

  db.settings = {
    -- booleans
    alwaysShowInfo = false, -- show info even when console is closed
    drawGraphs = false,
    pauseWorld = true, -- pause world when console is opened
    silenceOutput = false, -- db.log will not print visually
    printOutput = false, -- db.log will also print to the standard output
    tween = true,
    
    -- limits
    bufferLimit = 1000, -- maximum lines in the buffer
    historyLimit = 100, -- maximum entries in the command history
    
    -- timing
    multiEraseTime = 0.35,
    multiEraseCharTime = 0.025,
    cursorBlinkTime = 0.5,
    openTime = 0.1,
    
    -- spacial
    height = 400,
    infoWidth = 300,
    borderSize = 2,
    padding = 10,
    
    -- colors
    color = { 0.95, 0.95, 0.95, 1 },
    bgColor = { 0, 0, 0, 0.8 },
    borderColor = { 0.8, 0.8, 0.8, 0.85 },
    graphColor = { 0.7, 0.7, 0.7, 1 },
    graphTextColor = { 1, 1, 1, 1 },
    
    -- text
    font = love.graphics.newFont(db.path:gsub("%.", "/") .. "/inconsolata.otf", 18),
    graphFont = love.graphics.newFont(db.path:gsub("%.", "/") .. "/inconsolata.otf", 14),
    prompt = "> ",
    cursor = "|",
    infoSeparator = ": ",
    
    -- other
    initMessage = "Ammo v" .. ammo.version .. " debug console",
    initFile = initFile, -- if present, this batch file will be executed on initialisation
    graphLineStyle = "rough"
  }

  -- keyboard controls
  db.controls = {
    open = "`",
    pause = "",
    toggleInfo = "",
    toggleGraphs = "",
    up = "pageup",
    down = "pagedown",
    historyUp = "up",
    historyDown = "down",
    erase = "backspace",
    execute = "return"
  }
end

function db.clear()
  db.buffer = { index = 0 }
end

function db.reset(init)
  if not init then
    db.clear()
    db.resetSettings()
    db.removeAllInfo()
  end

  db.commands = {}
  db.help = {}
  db.include("default")

  if db.settings.initMessage then
    db.log(db.settings.initMessage)
  end

  -- default info graphs
  db.addGraph("FPS", love.timer.getFPS)
  db.addGraph("Memory", function() return ("%.2f MB"):format(collectgarbage("count") / 1024) end, function() return collectgarbage("count") / 1024 end)
  db.addGraph("Entities", function() return ammo.world and ammo.world.count or nil end)

  -- initialisation file
  if love.filesystem.getInfo(db.settings.initFile) then
    db.resetInProgress = true
    db.runBatch(db.settings.initFile)
    db.resetInProgress = false
  end
end

function db.log(...)
  local msg = db.joinWithSpaces(...)
  if not db.settings.silenceOutput then addToBuffer(msg) end
  if db.settings.printOutput then print(msg) end
end

function db.runCommand(line, ret)
  local terms = {}
  local quotes = false
  
  -- split and compile terms
  for t in line:gmatch("[^%s]+") do
    if quotes then
      terms[#terms] = terms[#terms] .. " " .. t
    else
      terms[#terms + 1] = t
      quotes = t:match("^[\"'$]")
    end
    
    if quotes and t:sub(-1) == quotes then
      quotes = false
      terms[#terms] = compileArg(terms[#terms])
    end
  end
  
  if terms[1] then
    local cmd = db.commands[terms[1]]
    
    if cmd then
      terms[1] = db -- replace the name with the self argument
      local result, msg = pcall(cmd, unpack(terms))
      
      if msg then
        if ret then
          return msg
        else
          db.log(msg)
        end
      end
    else
      db.log('No command named "' .. terms[1] .. '"')
    end
  end
end

function db.runBatch(file)
  for line in love.filesystem.lines(file) do
    db.runCommand(line)
  end
end

-- utility function for commands
function db.joinWithSpaces(...)
  local str = ""
  local args = { ... }
  
  for i, v in ipairs(args) do
    if type(v) == "boolean" then
      v = v and "true" or "false"
    else
      v = tostring(v)
    end
    
    str = str .. v .. (i == #args and "" or " ")
  end
  
  return str
end

function db.addInfo(title, func)
  db.info[#db.info + 1] = Info:new(db, title, func, false)
end

function db.addGraph(title, func, funcOrInterval, interval)
  local info
  
  if type(funcOrInterval) == "function" then
    info = Info:new(db, title, func, true, interval, funcOrInterval)
  else
    info = Info:new(db, title, func, true, funcOrInterval)
  end
  
  db.info[#db.info + 1] = info
end

function db.removeInfo(title)
  for i = 1, #db.info do
    if db.info[i].title == title then
      table.remove(db.info, i)
      break
    end
  end
end

function db.removeAllInfo()
  db.info = {}
end

function db.include(t)
  if type(t) == "string" then
    t = require(db.path .. ".commands." .. t)
  end

  for k, v in pairs(t) do 
    if type(v) == "function" then
      db.commands[k] = v
    elseif k == "help" or k == "_help" then
      for cmd, docs in pairs(v) do db.help[cmd] = docs end
    end
  end
end

function db.includeAll()
  for _, v in pairs{"console", "filesystem", "lua", "world"} do
    db.include(v)
  end
end

function db.exclude(t)
  if type(t) == "string" then
    if t == "default" then
      db.log("Cannot exclude the default module")
      return
    end

    t = require(db.path .. ".commands." .. t)
  end

  for k, v in pairs(t) do
    if type(v) == "function" then
      db.commands[k] = nil
    elseif k == "help" then
      for cmd in pairs(v) do db.help[cmd] = nil end
    end
  end
end

function db.open(tween)
  db.opened = true
  moveConsole(tween or db.settings.tween)
end

function db.close(tween)
  db.opened = false
  moveConsole(tween or db.settings.tween)
end

function db.toggle(tween)
  db.opened = not db.opened
  moveConsole(tween or db.settings.tween)
end

function db.check(path)
  if path then
    local file = convertPath(path)
    
    if file then
      local mod = love.filesystem.getInfo(file).modtime
      if modified[path] and mod ~= modified[path] then db.reload(path) end
      modified[path] = mod
    end
  else
    for path in pairs(package.loaded) do db.check(path) end
  end
end

function db.reload(path)
  path = convertPath(path)
  if not path then return "File doesn't exist" end
  
  local t = setmetatable({}, { __index = _G, __newindex = function(t, k, v)
    if type(_G[k]) ~= "table" then rawset(t, k, v) end
  end })
  
  local func, err = loadfile(path)
  if not func then return err end
  
  setfenv(func, t)
  local status, err = pcall(func)
  if not status then return err end
  for k, v in pairs(t) do _G[k] = v end
end

-- CALLBACKS --

function db.update(dt)
  if db.active then
    rejectInput = false

    -- cursor blink
    if timers.blink >= db.settings.cursorBlinkTime then
      timers.blink = -db.settings.cursorBlinkTime
    else
      timers.blink = timers.blink + dt
    end
    
    -- erasing characters
    if love.keyboard.isDown(db.controls.erase) and #db.input > 0 then
      if timers.multiErase == 0 then
        removeCharacter() -- first character when pressed
      elseif timers.multiErase > db.settings.multiEraseTime then
        -- rapidly erasing multiple characters
        if timers.multiEraseChar <= 0 then
          removeCharacter()
          timers.multiEraseChar = timers.multiEraseChar + db.settings.multiEraseCharTime
        else
          timers.multiEraseChar = timers.multiEraseChar - dt
        end
      end
      
      timers.multiErase = timers.multiErase + dt
      timers.blink = 0 -- always show the cursor
    else
      timers.multiErase = 0
      timers.multiEraseChar = 0
    end
  end
  
  for _, info in ipairs(db.info) do info:update(dt) end
  if db.tween and db.tween.active then db.tween:update(dt) end
end

local ceil = math.ceil -- for speed

function db.draw()
  local s = db.settings
  love.graphics.storeColor()
  
  if db.visible then
    -- background
    love.graphics.setColor(s.bgColor)
    love.graphics.rectangle("fill", 0, db.y, love.graphics.width, s.height)
    
    -- border
    love.graphics.setColor(s.borderColor)
    love.graphics.rectangle("fill", 0, db.y + s.height, love.graphics.width, s.borderSize)
    
    -- text
    local str = ""
    local rows = math.floor((s.height - s.padding * 2) / s.font:getHeight())
    local drawY = db.y + s.padding
    local begin = math.max(db.buffer.index - rows + 2, 1) -- add 1 for input line and 3 to keep in bounds (unsure why this is necessary)
    local consoleWidth = love.graphics.width - s.infoWidth - s.padding * 2
    local i = 0
    local used = 0
    local line

    while used < rows and i < db.buffer.index do
      line = db.buffer[db.buffer.index - i]
      str = line .. "\n" .. str
      i = i + 1
      used = used + ceil(s.font:getWidth(line) / consoleWidth)

      if used >= rows then
        drawY = drawY - s.font:getHeight() * (used - rows + 1)
      end
    end

    str = str .. s.prompt .. db.input
    if timers.blink >= 0 then str = str .. s.cursor end
    love.graphics.setFont(s.font)
    love.graphics.setColor(s.color)
    love.graphics.printf(str, s.padding, drawY, consoleWidth)
  end
  
  if db.visible or s.alwaysShowInfo then
    local x = love.graphics.width - s.infoWidth + s.padding
    local y = (s.alwaysShowInfo and 0 or db.y) + s.padding
    for _, info in ipairs(db.info) do y = y + info:draw(x, y) end
  end
  
  love.graphics.resetColor()
end

function db.keypressed(key, code)
  local c = db.controls
  
  if key == c.open then
    if not db.active then rejectInput = true end
    db.toggle()
    if db.settings.pauseWorld and ammo.world then ammo.world.active = not db.opened end
  elseif key == c.pause then
    if ammo.world then ammo.world.active = not ammo.world.active end
  elseif key == c.toggleInfo then
    db.settings.alwaysShowInfo = not db.settings.alwaysShowInfo
  elseif key == c.toggleGraphs then
    db.settings.drawGraphs = not db.settings.drawGraphs
  elseif db.active then
    if key == c.execute then
      handleInput()
    elseif key == c.historyUp then
      db.history.index = math.max(db.history.index - 1, 1)
      handleHistory()
    elseif key == c.historyDown then
      -- have to use if statement since handleHistory shouldn't be called if index is already one over #history
      if db.history.index < #db.history + 1 then
        db.history.index = db.history.index + 1
        handleHistory()
      end
    elseif key == c.up then
      db.buffer.index = math.max(db.buffer.index - 1, 0)
    elseif key == c.down then
      db.buffer.index = math.min(db.buffer.index + 1, #db.buffer)
    end
  end
end

function db.textinput(t)
  if db.active and not rejectInput then
    db.input = db.input .. t
    timers.blink = 0
  end
end

function db.focus(f)
  if db.live and f then db.check() end
end

-- update and draw taken by ammo
-- keypressed will likely be taken by input
if not love.textinput then love.textinput = db.textinput end
if not love.focus then love.focus = db.focus end

db.resetSettings()
return db
