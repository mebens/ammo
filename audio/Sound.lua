Sound = class("Sound")

function Sound:__index(key)
  local result = rawget(self, "_" .. key) or self.class.__instanceDict[key]
  
  if result then
    return result
  else
    local proto = rawget(self, '_multi') and rawget(self, '_protos')[1] or rawget(self, '_proto')

    -- calling Source method on SoundPool calls method to prototype Source(s)
    if proto[key] then
      Sound[key] = function(s, ...)
        if s._multi then
          for _, v in ipairs(s._protos) do
            v[key](v, ...)
          end
        else
          s._proto[key](s._proto, ...)
        end
      end

      return Sound[key]
    end
  end
end

local function createProto(data, srcType, volume)
  local proto

  if type(data) == "userdata" and data:typeOf("Source") then
    proto = data
  else
    proto = love.audio.newSource(data, srcType)
  end

  if volume then proto:setVolume(volume) end
  return proto
end

function Sound:initialize(data, volume, stream)
  self._data = data
  self._type = stream and "stream" or "static"

  if type(data) == "table" then
    self._multi = true
    self._protos = {}

    for i, v in ipairs(data) do
      self._protos[i] = createProto(v, self._type, type(volume) == "table" and volume[i] or volume)
    end
  else
    self._multi = false
    self._proto = createProto(data, self._type, volume)
  end
end

local rand = math.random

function Sound:play()
  local proto = self._multi and self._protos[rand(1, #self._protos)] or self._proto
  local src = proto:clone()
  src:play()
  return src
end
