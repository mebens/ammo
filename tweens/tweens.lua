local function processTable(t)
  local ease = t.ease
  local complete = t.complete
  local completeArgs = t.completeArgs
  t.ease = nil
  t.complete = nil
  t.completeArgs = nil
  if completeArgs ~= nil and type(completeArgs) ~= "table" then completeArgs = { completeArgs } end
  return t, ease, complete, completeArgs
end

local function animate(self, duration, t, ease, complete, ...)
  if not ammo._world then return end
  local tween = AttrTween:new(self, duration, t, ease, complete, ...)
  local world = self._world or ammo._world
  world:add(tween)
  return tween:start()
end

function delay(secs, func, ...)
  if not ammo._world then return end
  local t = Tween:new(secs, nil, func, ...)
  ammo._world:add(t)
  return t:start()
end

function tween(obj, duration, t, ease, complete, ...)
  if not ammo._world then return end
  local tween = AttrTween:new(obj, duration, t, ease, complete, ...)
  ammo._world:add(tween)
  return tween:start()
end

Entity.animate = animate
Camera.animate = animate
