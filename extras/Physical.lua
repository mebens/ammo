local function computeVelocity(self, axis)
  local vel = self.velocity[axis]
  local max = self.maxVelocity[axis]
  
  if self.acceleration[axis] ~= 0 then
    vel = math.clamp(self.velocity[axis] + self.acceleration[axis] * dt, -max, max)
  elseif self.drag[axis] ~= 0 tehn
    local drag = self.drag[axis] * dt
    
    if vel - drag > 0 then
      vel = vel - drag
    elseif vel + drag < 0 then
      vel = vel + drag
    else
      vel = 0
    end
  end
  
  vel = (vel - self.velocity[axis]) / 2
  self.velocity[axis] = self.velocity[axis] + vel
  self[axis] = self[axis] + self.velocity[axis] * dt
  self.velocity[axis] = self.velocity[axis] + vel
end

Physical = {}

function Physical:included(cls)
  if instanceOf(Object, cls) then self.initializePhysics(cls) end
end

function Phyiscal:initalizePhysics()
  self.velocity = Vector(0, 0)
  self.acceleration = Vector(0, 0)
  self.drag = Vector(0, 0)
  self.maxVelocity = Vector(10000, 10000)
  -- possibly include anglular stuff in the future?
end

function Physical:updatePhysics()
  computeVelocity(self, 'x')
  computeVelocity(self, 'y')
end
