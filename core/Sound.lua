Sound = class("Sound")
Sound._mt = {}

function Sound._mt:__index(key)
  return rawget(self, "_" .. key) or self.class.__instanceDict[key]
end

Sound:enableAccessors()

function Sound:initialize(file, long, volume, pan)
  self._file = file
  self._long = long or false
  self.defaultVolume = volume or 1
  self.defaultPan = pan or 0
  
  if self._long then
    self._data = file
  else
    self._data = love.sound.newSoundData(file)
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

for _, v in pairs{"pause", "resume", "rewind", "stop"} do
  Sound[v] = function(self, last)
    if last and self._sources[#self._sources] then
      self._sources[#self._sources][v]()
    else
      for _, s in pairs(self._sources) do s[v]() end
    end
  end
end
