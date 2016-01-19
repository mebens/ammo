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
      assets.loadImage(value, key)
    else
      rawset(self, key, value)
    end
  end
})

assets.sfx = setmetatable({}, {
  __newindex = function(self, key, value)
    if type(value) == "string" then
      assets.loadSfx(value, key)
    else
      rawset(self, key, value)
    end
  end
})

assets.music = setmetatable({}, {
  __newindex = function(self, key, value)
    if type(value) == "string" then
      assets.loadMusic(value, key)
    else
      rawset(self, key, value)
    end
  end
})

assets.shaders = setmetatable({}, {
  __newindex = function(self, key, value)
    if type(value) == "string" then
      assets.loadEffect(value, key)
    else
      rawset(self, key, value)
    end
  end
})

-- can't do it here because fonts require a size
assets.fonts = {}

function assets.get(key)
  return assets.images[key] or assets.sfx[key] or assets.music[key] or assets.shaders[key] or assets.fonts[key]
end

function assets.loadImage(file, name)
  local img = love.graphics.newImage(assets.getPath(file, "image"))
  rawset(assets.images, name or assets.getName(file), img)
  return img
end

function assets.loadSfx(file, name, volume, long)
  if type(name) == "number" then
    volume = name
    name = nil
  end
  
  local sound = Sound:new(assets.getPath(file, "sfx"), long or false, volume)
  rawset(assets.sfx, name or assets.getName(file), sound)
  return sound
end

function assets.loadMusic(file, name)
  local sound = Sound:new(assets.getPath(file, "music"), true)
  rawset(assets.music, name or assets.getName(file), sound)
  return sound
end

function assets.loadShader(file, name)
  local source = love.filesystem.read(assets.getPath(file, "shader"))
  local shader = love.graphics.newShader(source)
  rawset(assets.shaders, name or assets.getName(file), shader)
  return shader
end

function assets.loadFont(file, size, name)
  name = name or assets.getName(file)
  size = size or 12
  
  if type(size) == "table" then
    for i = 1, #size do assets.loadFont(file, size[i], name) end
    return assets.fonts[name]
  end
  
  local font = love.graphics.newFont(assets.getPath(file, "font"), size)
  if not assets.fonts[name] then assets.fonts[name] = {} end
  assets.fonts[name][size] = font
  return font
end

function assets.getName(path)
  return assets.removeExtension(path:match("([^/]+)$"))
end

function assets.getPath(file, type)
  return assets.path .. "/" .. assets[type .. "Path"] .. "/" .. file
end

function assets.removeExtension(path)
  return path:match("^([^%.]*)%.?")
end

return assets
