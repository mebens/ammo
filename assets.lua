local function matchType(file, name)
  if type(file) == "table" then file = file[1] end

  if name then
    local types = assets.types[name]

    for _, ext in ipairs(assets.types[name]) do
      if file:match(ext .. "$") then
        return true
      end
    end

    return false
  else
    local func

    for name, _ in pairs(assets.types) do
      if matchType(file, name) then
        return assets["new" .. name:gsub("^.", string.upper)]
      end
    end

    error("Unable to automatically match asset type to file '" .. file .. "'")
  end
end

local assets = setmetatable({}, {
  __index = function(self, key) return self.get(key) end,
  __call = function(self, ...)
    local args = {...}
    local func

    if #args == 1 and type(args[1]) == "table" then
      for key, val in pairs(args[1]) do
        func = matchType(val)
        func(val, type(key) ~= "number" and key or nil)
      end
    else
      for _, f in ipairs(args) do
        func = matchType(f)
        func(f)
      end
    end
  end
})

assets.path = "assets"
assets.types = {}

function assets.get(key)
  return assets.images[key] or assets.sfx[key] or assets.music[key] or assets.shaders[key] or assets.fonts[key]
end

function assets.newType(name, plural, path, types, loadFunc)
  local t = setmetatable({}, {
    __call = function(self, ...)
      local args = {...}

      if #args == 1 and type(args[1]) == "table" then
        for key, val in pairs(args[1]) do
          loadFunc(val, type(key) ~= "number" and key or nil)
        end
      else
        for _, f in ipairs(args) do
          loadFunc(f)
        end
      end
    end
  })

  plural = plural or name .. "s"
  path = path or plural
  assets[name] = t
  assets[plural] = t
  assets["new" .. name:gsub("^.", string.upper)] = loadFunc
  assets[name .. "Path"] = path

  if types then
    assets.types[name] = type(types) == "string" and { types } or types
  end

  assets["all" .. plural:gsub("^.", string.upper)] = function()
    for _, f in ipairs(love.filesystem.getDirectoryItems(assets.getPath(nil, name))) do
      if not assets.types[name] then
        loadFunc(f)
      elseif matchType(f, name) then
        loadFunc(f)
      end
    end
  end
end

-- isolates file names, and camelcases it where punctuation separates words
function assets.getName(path, multi)
  if multi then
    local stripEnd = path:match("([^/]+)([%-_]?%d+)%.[^%.]+$") -- strip ending number

    if stripEnd then
      path = stripEnd
    else
      multi = false -- use the matching below
    end
  end

  if not multi then
    path = path:match("([^/]+)%.[^%.]+$")
  end

  path = path:gsub("%p(%w)", string.upper)
  return path
end

function assets.getPath(file, type)
  return (assets.path and (assets.path .. "/") or "") .. assets[type .. "Path"] .. "/" .. (file or "")
end

assets.newType("image", nil, nil, { "png", "jpg", "jpeg", "tga", "bmp" }, function (file, name)
  local img = love.graphics.newImage(assets.getPath(file, "image"))
  rawset(assets.images, name or assets.getName(file), img)
  return img
end)

assets.newType("sfx", "sfx", nil, { "ogg", "oga", "wav", "mp3" }, function (file, name, pool, volume, stream)
  if type(name) == "boolean" then
    stream = volume
    volume = pool
    pool = name
    name = nil
  elseif type(name) == "number" then
    volume = name
    stream = pool
    pool = false
    name = nil
  end
  
  if type(file) == "table" then
    if not name then
      name = assets.getName(file[1], true)
    end

    for i, v in ipairs(file) do
      file[i] = assets.getPath(file[i], "sfx")
    end
  else
    file = assets.getPath(file, "sfx")
  end

  local sound

  if pool then
    sound = SoundPool:new(file, volume or 1, stream)
  elseif Sound then
    sound = Sound:new(file, volume or 1, stream)
  else
    sound = love.audio.newSource(file, stream and "stream" or "static")
    if volume then sound:setVolume(volume) end
  end

  rawset(assets.sfx, name or assets.getName(file), sound)
  return sound
end)

assets.newType("music", "music", nil, nil, function (file, name, volume)
  if type(name) == "number" then
    volume = name
    name = nil
  end

  local sound

  if Sound then
    sound = Sound:new(assets.getPath(file, "music"), volume or 1, true)
  else
    sound = love.audio.newSource(file, "stream")
    if volume then sound:setVolume(volume) end
  end
  
  rawset(assets.music, name or assets.getName(file), sound)
  return sound
end)

assets.newType("shader", nil, nil, { "frag", "vert", "glsl", "shader" }, function (file, fileOrName, name)
  local source = love.filesystem.read(assets.getPath(file, "shader"))
  local shader

  if name then
    local source2 = love.filesystem.read(assets.getPath(fileOrName, "shader"))
    shader = love.graphics.newShader(source, source2)
  else
    shader = love.graphics.newShader(source)
    name = fileOrName
  end

  rawset(assets.shaders, name or assets.getName(file), shader)
  return shader
end)

assets.newType("font", nil, nil, { "ttf", "otf" }, function (file, size, name)
  -- support for assets.fonts() syntax
  if type(file) == "table" then
    size = file[2]
    name = file[3]
    file = file[1]
  end

  name = name or assets.getName(file)
  size = size or 12

  if type(size) == "table" then
    for i = 1, #size do assets.newFont(file, size[i], name) end
    return assets.fonts[name]
  end
  
  local font = love.graphics.newFont(assets.getPath(file, "font"), size)
  if not assets.fonts[name] then assets.fonts[name] = {} end
  assets.fonts[name][size] = font
  return font
end)

return assets
