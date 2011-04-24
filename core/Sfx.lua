Sfx = class('Sfx')

Sfx._mt = {}

function Sfx._mt:__index(key)
  if key == 'file' then
    return self._file
  else
    return Sfx.__classDict[key]
  end
end

function Sfx:initialize(file)
  self._data = love.sound.newSoundData(file)
  self._file = file
  self._sources = {}
  table.insert(love.audio._sounds, self)
  
  local old = getmetatable(self)
  old.__index = Sfx._mt.__index
end

function Sfx:play(x, y, volume, pan)
  local source = love.audio.newSource(self._data, 'stream')
  
  if not volume then
    local dist = Vector.dist(Vector(camera.x + love.graphics.getWidth(), camera.y + love.graphics.getHeight()), Vector(x, y))
    volume = math.clamp(1 / (dist / 100), .025, .3)
  end

  source:setVolume(volume)
  source:setPosition(pan or 0, 0, 0)
  source:play()
  table.insert(self._sources, source)
  return source
end

for _, v in pairs{'pause', 'resume', 'rewind', 'stop'} do
  Sfx[v] = function(self, last)
    if last and self._sources[#self._sources] then
      self._sources[#self._sources][v]()
    else
      for _, s in pairs(self._sources) do s[v]() end
    end
  end
end