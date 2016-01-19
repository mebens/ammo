PhysicalWorld = class("PhysicalWorld", World)
PhysicalWorld.static.maxDelta = .03
PhysicalWorld._mt = {}

function PhysicalWorld._mt:__index(key)
  local result = World._mt.__index(self, key)
  
  if result then
    return result
  elseif self._world[key] then
    PhysicalWorld[key] = function(s, ...) return s._world[key](s._world, ...) end
    return PhysicalWorld[key]
  end
end 

PhysicalWorld:enableAccessors()

function PhysicalWorld:initialize(...)
  World.initialize(self)
  self.physicsActive = true
  self._world = love.physics.newWorld(...)
  self._world:setCallbacks(PhysicalWorld._onCollide)
  self:applyAccessors()
end

function PhysicalWorld:update(dt)
  if self.physicsActive then
    if dt > PhysicalWorld.maxDelta then
      local current = dt
      
      while current > PhysicalWorld.maxDelta do
        current = current - PhysicalWorld.maxDelta
        self._world:update(PhysicalWorld.maxDelta)
      end
      
      self._world:update(current)
    else
      self._world:update(dt)
    end
  end
  
  World.update(self, dt)
end

function PhysicalWorld:wakeAll()
  for v in self._updates:iterate() do
    if instanceOf(PhysicalEntity, v) and v._body then
      v._body:wakeUp()
    end
  end
end

function PhysicalWorld:sleepAll()
  for v in self._updates:iterate() do
    if instanceOf(PhysicalEntity, v) and v._body then
      v._body:putToSleep()
    end
  end
end

function PhysicalWorld._onCollide(a, b, contact)
  local entityA = a:getUserData()
  local entityB = b:getUserData()
  
  if entityA.collided and not entityA._removalQueued then
    entityA:collided(entityB, a, b, contact)
  end
  
  if entityB.collided and not entityB._removalQueued then
    entityB:collided(entityA, a, b, contact)
  end
end
