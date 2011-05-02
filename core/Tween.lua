Tween = class('Tween')
Tween.PERSIST = 1
Tween.LOOPING = 2
Tween.ONESHOT = 3

-- METATABLE --

Tween._mt = {}

function Tween._mt:__index(key)
  if self.class.__classDict[key] then
    return self.class.__classDict[key]
  elseif rawget(self, '_' .. key) then
    return self['_' .. key]
  elseif key == 'percent' then
    return self._time / self._target
  elseif key == 'scale' then
    return self._t
  elseif key == 'elapsed' then
    return self._time
  elseif key == 'duration' then
    return self._target
  elseif key == 'remaining' then
    return self._target - self._time
  end
end

function Tween._mt:__newindex(key, value)
  if key == 'percent' then
    self._time = self._target * value -- value is a 0 - 1 value
  elseif key == 'duration' then
    if not self.active then
      self._target = value
    end
  else
    rawset(self, key, value)
  end
end

Tween:enableAccessors()

-- METHODS --

function Tween:initialize(duration, tweenType, complete, ease)
  -- settings
  self.active = false
  self.type = tweenType or Tween.PERSIST
  self.useFrames = false
  
  -- functions
  self.complete = complete
  self.ease = ease
  
  -- time info
  self._target = duration or 1
  self._time = 0
  self._t = 0
  
  self:applyAccessors()
end

function Tween:update(dt)
  self._time = self._time + (self.useFrames and 1 or dt)
  self._t = self._time / self._target
  
  if self.ease and self._t > 0 and self._t < 1 then
    self._t = self.ease(self._t)
  end
  
  -- are we done?
  if self._time >= self._target then
    self._t = 1
    self:_finish()
    if self.complete then self.complete() end
  end
end

function Tween:start()
  self.active = true
  return self
end

function Tween:stop()
  self.active = false
  self:_finish() -- hmmmm, things could go wrong here, but oh well
  return self
end

function Tween:_finish()
  if self.type == Tween.PERSIST then
    self._time = self._target
    self.active = false
  elseif self.type == Tween.LOOPING then
    self._time = self._time % self._target
    self._t = self._time / self._target
    
    if self._ease and self._t > 0 and self._t < 1 then
      self._t = self.ease(self._t)
    end
    
    self.active = true
  elseif self.type == Tween.ONESHOT then
    self._time = self._target
    self.active = false
    if self._world then self._world:remove(self) end
  end
end