PhysicalEntity = class("PhysicalEntity", Entity)

function PhysicalEntity:__index(key)
  if key == "velx" then
    return self._velocity.x
  elseif key == "vely" then
    return self._velocity.y
  else
    local result = Entity.__index(self, key)
    
    if result then
      return result
    elseif rawget(self, "_body") and self._body[key] then
      PhysicalEntity[key] = function(s, ...) return s._body[key](s._body, ...) end
      return PhysicalEntity[key]
    end
  end
end

function PhysicalEntity:__newindex(key, value)
  if key == "x" then
    self._pos.x = value
    if self._body then self._body:setX(value) end
  elseif key == "y" then
    self._pos.y = value
    if self._body then self._body:setY(value) end
  elseif key == "pos" then
    self._pos = value
    if self._body then self._body:setPosition(value.x, value.y) end
  elseif key == "angle" then
    self._angle = value
    if self._body then self._body:setAngle(value) end
  elseif key == "velx" then
    self._velocity.x = value
    if self._body then self._body:setLinearVelocity(value, self._velocity.y) end
  elseif key == "vely" then
    self._velocity.y = value
    if self._body then self._body:setLinearVelocity(self._velocity.x, value) end
  elseif key == "velocity" then
    self._velocity = value
    if self._body then self._body:setLinearVelocity(value.x, value.y) end
  else
    Entity.__newindex(self, key, value)
  end
end

function PhysicalEntity:initialize(x, y, type)
  Entity.initialize(self, x, y)
  self._velocity = Vector(0, 0)
  self._angle = 0
  self.bodyType = type or "static"
end

function PhysicalEntity:update(dt)
  if self._body then
    self._pos.x, self._pos.y = self._body:getPosition()
    self._velocity.x, self._velocity.y = self._body:getLinearVelocity()

    if self.noRotate then
      self._body:setAngle(0)
      self._angle = 0
    else
      self._angle = self._body:getAngle()
    end
  end
end

--[[ Format for the collided function
function PhysicalEntity:collided(other, fixture, otherFixture, contact)
  
end
]]

function PhysicalEntity:destroy()
  if self._body then
    self._body:destroy()
    self._body = nil
  end
end

function PhysicalEntity:setupBody(type)
  if self._world then
    self._body = love.physics.newBody(self._world._world, self._pos.x, self._pos.y, type or self.bodyType)
    self._body:setAngle(self._angle)
    self._body:setLinearVelocity(self._velocity.x, self._velocity.y)
  end
end

PhysicalEntity.added = PhysicalEntity.setupBody
PhysicalEntity.removed = PhysicalEntity.destroy

function PhysicalEntity:addShape(shape, density)
  local fixture = love.physics.newFixture(self._body, shape, density or 1)
  fixture:setUserData(self)
  return fixture
end

function PhysicalEntity:drawShape(fixture)
  local shape = fixture:getShape()
  local shapeType = shape:getType()
  
  if shapeType == 'polygon' then
    love.graphics.polygon("line", self:getWorldPoints(shape:getPoints()))
  elseif shapeType == 'circle' then
    local x, y = self:getWorldPoint(shape:getPoint())
    love.graphics.circle("line", x, y, shape:getRadius())
  end
end
