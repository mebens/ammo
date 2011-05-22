function setIdentity(to)
  love.filesystem.setIdentity('tmp')
  local new = ""
  local path = love.filesystem.getSaveDirectory()
  path = path:match("/(.+)") or path:match("%s:/(.+)")
  for s in path:gmatch("/") do new = new .. "../" end
  love.filesystem.setIdentity(new .. (to and to:gsub('^/', '') or ""))
end

function loadClasses(obj, clsType)
  if type(obj) == 'string' then
    for _, v in ipairs(love.filesystem.enumerate(obj:gsub('%.', '/'))) do
      local filename = v:gsub('%.lua$', '')
      if v:endsWith('.lua') then require(obj .. '.' .. filename) end
      
      if clsType then
        table.insert(
          Editor[clsType == 'entity' and 'entities' or 'worlds'],
          Editor.config.className(filename, clsType)
        )
      end
    end
  else
    for _, v in ipairs(obj) do loadClasses(v) end
  end
end
