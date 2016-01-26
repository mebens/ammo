local Delay = class("Delay")

function Delay:initialize(duration, complete, ...)
  self.active = true
  self.time = 0
  self.duration = duration
  self.complete = complete
  self.completeArgs = { ... }
end

function Delay:update(dt)
  self.time = self.time + dt

  if self.time >= self.duration then
    self.complete(unpack(self.completeArgs))
    self.active = false
    self.world = nil
  end
end

----------------------

function delay(secs, func, ...)
  if not ammo._world then return end
  local d = Delay:new(secs, func, ...)
  ammo._world:add(d)
  return d
end

local function objDelay(self, secs, func, ...)
  if not self._world then return end
  local d = Delay:new(secs, func, ...)
  self._world:add(d)
  return d
end

Entity.delay = objDelay
Camera.delay = objDelay
