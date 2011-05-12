-- This is for love.physics. For custom physics, see Physical.

PhysicalEntity = class('PhysicalEntity', Entity)

-- METATABLE --

PhysicalEntity._mt = {}

function PhysicalEntity._mt:__index(key)
  if key == 'velx' then
    return self._velocity.x
  elseif key == 'vely' then
    return self._velocity.y
  else
    return Entity._mt.__index(self, key)
  end
end

function PhysicalEntity._mt:__newindex(key, value)
  if key == 'x' then
    self._pos.x = value
    if self._body then self._body:setX(value) end
  elseif key == 'y' then
    self._pos.y = value
    if self._body then self._body:setY(value) end
  elseif key == 'pos' then
    self._pos = value
    if self._body then self._body:setPosition(value.x, value.y) end
  elseif key == 'rotation' then
    self._rotation = value
    if self._body then self._body:setAngle(value) end
  elseif key == 'velx' then
    self._velocity.x = value
    local vx, vy = self._body:getLinearVelocity()
    if self._body then self._body:setLinearVelocity(value, vy) end
  elseif key == 'vely' then
    self._velocity.y = value
    local vx, vy = self._body:getLinearVelocity()
    if self._body then self._body:setLinearVelocity(vx, value) end
  elseif key == 'velocity' then
    self._velocity = value
    if self._body then self._body:setLinearVelocity(value.x, value.y) end
  else
    Entity._mt.__newindex(self, key, value)
  end
end

PhysicalEntity:enableAccessors()

-- METHODS --

function PhysicalEntity:initialize(t)
  Entity.initialize(self, t)
  self._velocity = Vector(0, 0)
  self._rotation = 0
  self._shapes = {}
  self:applyAccessors()
end

function PhysicalEntity:update(dt)
  if self._body then
    self._pos.x, self._pos.y = self._body:getPosition()
    self._velocity.x, self._velocity.y = self._body:getLinearVelocity()

    if self.noRotate then
      self._body:setAngle(0)
      self._rotation = 0
    else
      self._rotation = self._body:getAngle()
    end
  end
end

function PhysicalEntity:collided(shape, other, otherShape, collision)
  
end

function PhysicalEntity:destroy()
  if self._body then
    for _, v in pairs(self._shapes) do
      v:setCategory(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16)
    end

    delayFrames(1, function()
      for _, v in pairs(self._shapes) do
        v:destroy()
      end
      
      self._shapes = {}
      
      if self._body then
        self._body:destroy()
        self._body = nil
      end
    end)
  end
end

function PhysicalEntity:rotate(dr)
  self.rotation = self.rotation + dr
end

function PhysicalEntity:setupBody(mass, inertia)
  if self._world then
    self._body = love.physics.newBody(self._world._world, self._pos.x, self._pos.y, mass, inertia)
    if self._rotation ~= 0 then self._body:setAngle(self._rotation) end
  end
end

function PhysicalEntity:newCircleShape(x, y, radius)
  if self._body then
    local shape = love.physics.newCircleShape(self._body, x, y, radius)
    shape:setData{self = self, shape = shape}
    table.insert(self._shapes, shape)
    return shape
  end
end

function PhysicalEntity:newPolygonShape(...)
  if self._body then
    local shape = love.physics.newPolygonShape(self._body, ...)
    shape:setData{self = self, shape = shape}
    table.insert(self._shapes, shape)
    return shape
  end
end

function PhysicalEntity:newRectangleShape(x, y, width, height, angle)
  if self._body then
    local shape = love.physics.newRectangleShape(self._body, x, y, width, height, angle)
    shape:setData{self = self, shape = shape}
    table.insert(self._shapes, shape)
    return shape
  end
end

function PhysicalEntity:newDistanceJoint(other, x1, y1, x2, y2)
  if self._body and other._body then
    return love.physics.newDistanceJoint(self._body, other._body, x1, y1, x2, y2)
  end
end

function PhysicalEntity:newRevoluteJoint(other, x, y)
  if self._body and other._body then
    return love.physics.newRevoluteJoint(self._body, other._body, x, y)
  end
end

-- TODO other joint functions

for _, v in pairs{'applyForce', 'applyImpulse', 'applyTorque', 'destroy', 
                  'getAllowSleeping', 'getAngle', 'getAngularDamping',
                  'getAngularVelocity', 'getInertia', 'getLinearDamping',
                  'getLinearVelocity', 'getLinearVelocityFromLocalPoint',
                  'getLinearVelocityFromWorldPoint', 'getLocalCenter',
                  'getLocalPoint', 'getLocalVector', 'getMass', 'getWorldCenter',
                  'getWorldPoint', 'getWorldVector', 'isBullet', 'isDynamic',
                  'isFrozen', 'isSleeping', 'isStatic', 'putToSleep',
                  'setAllowSleeping', 'setAngle', 'setAngularDamping',
                  'setAngularVelocity', 'setBullet', 'setFixedRotation',
                  'setInertia', 'setLinearDamping', 'setMass', 'setMassFromShapes',
                  'wakeUp'} do
  PhysicalEntity[v] = function(self, ...)
    return self._body[v](self._body, ...)
  end
end
