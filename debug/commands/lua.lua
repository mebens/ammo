-- commands relating to Lua and its standard libraries
local t = {}

function t:gc(opt, arg)
  local result = collectgarbage(opt, arg and tonumber(arg))
  
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

return t
