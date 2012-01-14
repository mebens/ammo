-- SOUND --

Sound = class('Sound')
Sound._mt = {}

function Sound._mt:__index(key)
  if key == 'file' then
    return self._file
  else
    return self.class.__classDict[key]
  end
end

Sound:enableAccessors()

function Sound:initialize(file, type, volume, pan)
  self._file = file
  self._type = type or "short"
  self._sources = {}
  self.defaultVolume = volume or 1
  self.defaultPan = pan or 0
  
  if self._type == "short" then
    self._data = love.sound.newSoundData(file)
  else
    self._data = file
  end
  
  self:applyAccessors()
  table.insert(love.audio._sounds, self)
end

function Sound:play(volume, pan)
  local source = love.audio.newSource(self._data, "stream")
  source:setVolume(volume or self.defaultVolume)
  source:setPosition(pan or self.defaultPan, 0, 0)
  source:play()
  table.insert(self._sources, source)
  return source
end

for _, v in pairs{'pause', 'resume', 'rewind', 'stop'} do
  Sound[v] = function(self, last)
    if last and self._sources[#self._sources] then
      self._sources[#self._sources][v]()
    else
      for _, s in pairs(self._sources) do s[v]() end
    end
  end
end