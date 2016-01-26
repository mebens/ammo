function tween(obj, duration, t, ease, complete, ...)
  local world = obj.world or ammo._world
  if not world then return end
  local tweenObj = Tween:new(obj, duration, t, ease, complete, ...)
  world:add(tweenObj)
  return tweenObj
end

Entity.animate = tween
Camera.animate = tween

----------------------

Tween = class('Tween')

function Tween:__index(key)
  return rawget(self, "_" .. key) or self.class.__instanceDict[key]
end

function Tween:initialize(obj, duration, values, ease, complete, ...)
  self.active = true
  self.time = 0
  self.ease = ease
  self.complete = complete
  self.completeArgs = { ... }
  self._obj = obj
  self._init = {}
  self._range = {}
  
  for k, v in pairs(values) do
    local val = obj[k]
    
    if val then
      self._init[k] = val
      self._range[k] = v - val
    end
  end

  if type(duration) == "string" then
    local tweenTime, delayTime = duration:match("([%w%.%-]+):([%w%.%-]+)")
    self.duration = tonumber(tweenTime)
    self.delay = tonumber(delayTime)
    self.delayTime = self.delay
  else
    self.duration = duration or 1
    self.delay = 0
    self.delayTime = 0
  end
end

function Tween:update(dt)
  if self.delayTime > 0 then
    self.delayTime = self.delayTime - dt
  else
    self.time = self.time + dt
    local t = self.time / self.duration
    
    -- need to clamp time before applying values, therefore it appears up here
    if t >= 1 then
      self.time = self.duration
      t = 1
    end
    
    if self.ease and t > 0 and t < 1 then
      t = self.ease(t)
    end
    
    for k, v in pairs(self._init) do
      self._obj[k] = v + self._range[k] * t
    end
    
    if t >= 1 then
      self:_finish()
      if self.complete then self.complete(unpack(self.completeArgs)) end
    end
  end
end

function Tween:start()
  self.active = true
  return self
end

function Tween:pause()
  self.active = false
  return self
end

function Tween:stop()
  self.time = 0
  self:_finish()
  return self
end

function Tween:_finish()
  self.active = false
  if self._world then self._world:remove(self) end
end

