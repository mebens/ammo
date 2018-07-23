-- commands relating to Lua and its standard libraries
local t = {}

function t:gc(opt, arg)
  local result = collectgarbage(opt or "collect", arg and tonumber(arg) or nil)
  
  -- collect, stop, and restart only return 0
  if opt == "count" or opt == "step" or opt == "setpause" or opt == "setstepmul" then
    return result
  end
end

function t:time()
  return os.time()
end

function t:date(format, time)
  return os.date(format, tonumber(time))
end

t.help = {
  gc = {
    args = "[[opt] arg]",
    summary = "Calls Lua's collectgarbage function.",
    description = "Calls collectgarbage(opt, arg).\nSee Lua's manual for details on this function's options."
  },

  time = {
    summary = "Prints os.time()"
  },

  date = {
    args = "[format [time]]",
    summary = "Prints os.date(format, time).",
    description = "Defaults to current time. See Lua's manual for details on the function, its possible formats, and arguments."
  }
}

return t
