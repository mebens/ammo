local assets = setmetatable({}, {
  __index = function(self, key) return self.get(key) end
})

assets.path = "assets"
assets.imagePath = "images"
assets.sfxPath = "sfx"
assets.musicPath = "music"
assets.shaderPath = "shaders"
assets.fontPath = "fonts"

assets.images = setmetatable({}, {
  __newindex = function(self, key, value)
    if type(value) == "string" then
      assets.image(value, key)
    else
      rawset(self, key, value)
    end
  end,

  __call = function(self, ...)
    local args = {...}

    if type(args[1]) == "table" then
      for key, val in pairs(args[1]) do
        assets.image(val, key)
      end
    else
      for _, f in ipairs{...} do
        assets.image(f)
      end
    end
  end
})

assets.sfx = setmetatable({}, {
  __newindex = function(self, key, value)
    if type(value) == "string" then
      assets.sfx(value, key)
    else
      rawset(self, key, value)
    end
  end,

  __call = function(self, ...)
    local args = {...}

    if type(args[1]) == "table" then
      for key, val in pairs(args[1]) do
        assets.sfx(val, key)
      end
    else
      for _, f in ipairs{...} do
        assets.sfx(f)
      end
    end
  end
})

assets.music = setmetatable({}, {
  __newindex = function(self, key, value)
    if type(value) == "string" then
      assets.music(value, key)
    else
      rawset(self, key, value)
    end
  end,

  __call = function(self, ...)
    local args = {...}

    if type(args[1]) == "table" then
      for key, val in pairs(args[1]) do
        assets.music(val, key)
      end
    else
      for _, f in ipairs{...} do
        assets.music(f)
      end
    end
  end
})

assets.shaders = setmetatable({}, {
  __newindex = function(self, key, value)
    if type(value) == "string" then
      assets.shader(value, key)
    else
      rawset(self, key, value)
    end
  end,

  __call = function(self, ...)
    local args = {...}

    if type(args[1]) == "table" then
      for key, val in pairs(args[1]) do
        assets.shader(val, key)
      end
    else
      for _, f in ipairs{...} do
        assets.shader(f)
      end
    end
  end
})

-- can't do it here because fonts require a size
assets.fonts = {}

function assets.get(key)
  return assets.images[key] or assets.sfx[key] or assets.music[key] or assets.shaders[key] or assets.fonts[key]
end

function assets.image(file, name)
  local img = love.graphics.newImage(assets.getPath(file, "image"))
  rawset(assets.images, name or assets.getName(file), img)
  return img
end

function assets.sfx(file, name, pool, volume, stream)
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
      file[i] = assets.getPath(file, "sfx")
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
end

function assets.music(file, name, volume)
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
end

function assets.shader(file, fileOrName, name)
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
end

function assets.font(file, size, name)
  name = name or assets.getName(file)
  size = size or 12
  
  if type(size) == "table" then
    for i = 1, #size do assets.font(file, size[i], name) end
    return assets.fonts[name]
  end
  
  local font = love.graphics.newFont(assets.getPath(file, "font"), size)
  if not assets.fonts[name] then assets.fonts[name] = {} end
  assets.fonts[name][size] = font
  return font
end

-- isolates file names, and camelcases it where punctuation separates words
function assets.getName(path, multi)
  if multi then
    path = path:match("([^/]+)[%-_]?%d?%.[^%.]+$") -- strip ending number
  else
    path = path:match("([^/]+)%.[^%.]+$")
  end

  return path:gsub("%p(%w)", string.upper)
end

function assets.getPath(file, type)
  return (assets.path and (assets.path .. "/") or "") .. assets[type .. "Path"] .. "/" .. file
end

return assets
