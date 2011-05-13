Music = class('Music')
Music._mt = {}

function Music._mt:__index(key)
  if key == 'file' then
    return self._file
  else
    return Music.__classDict[key]
  end
end

function Music:initialize(file, volume, pan)
  self._file = file
  self._sources = {}
  self.defaultVolume = volume or 1
  self.defaultPan = pan or 0
  self:applyAccessors()
  table.insert(love.audio._sounds, self)
end

function Music:play(x, y, volume, pan)
  local source = love.audio.newSource(self._file, 'stream')
  source:setVolume(volume or self.defaultVolume)
  source:setPosition(pan or self.defaultPan, 0, 0)
  source:play()
  table.insert(self._sources, source)
  return source
end

for _, v in pairs{'pause', 'resume', 'rewind', 'stop'} do
  Music[v] = function(self, last)
    if last and self._sources[#self._sources] then
      self._sources[#self._sources][v]()
    else
      for _, s in pairs(self._sources) do s[v]() end
    end
  end
end
