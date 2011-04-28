-- X MODULE --

x = setmetatable({}, {
  __index = function(self, key) return self['_' .. key] end,
  
  __newindex = function(self, key, value)
    if key == 'world' then
      self._goto = value
    elseif key == 'camera' then
      if self._camera then self._camera:unset() end
      if value then value:set() end
      self._camera = value
    else
      rawset(self, key, value)
    end
  end
})

function x.update(dt)
  -- update
  if x._world then x._world:update(dt) end
  love.audio.update()
  
  -- world switch
  if x._goto then
    if x._world then x._world:stop() end
    x._world = x._goto
    x._goto = nil
    if x._world then x._world:start() end
  end
end

function x.draw()
  if x._world then
    if x._camera then x._camera:unset() end
    x._world:draw()
    if x._camera then x._camera:set() end
  end
end

-- GLOBAL FUNCTIONS --

function delay(secs, func)
  if not world then return end
  local t = Tween:new(secs, Tween.ONESHOT, func)
  world:add(t)
  return t:start()
end

function delayFrames(frames, func)
  if not world then return end
  local t = Tween:new(secs, Tween.ONESHOT, func)
  world:add(t)
  t.useFrames = true
  return t:start()
end

function tween(obj, duration, t)
  if not world then return end
  
  local ease = t.ease
  local onComplete = t.onComplete
  t.ease = nil
  t.onComplete = nil
  
  local t = AttrTween:new(obj, duration, t, Tween.ONESHOT, onComplete, ease)
  world:add(t)
  return t:start()
end
