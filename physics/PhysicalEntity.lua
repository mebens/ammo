PhysicalEntity = class("PhysicalEntity", Entity)

function PhysicalEntity:__index(key)
  local result = Entity.__index(self, key)
  
  if result then
    return result
  elseif rawget(self, "_body") and self._body[key] then
    PhysicalEntity[key] = function(s, ...) return s._body[key](s._body, ...) end
    return PhysicalEntity[key]
  end
end

function PhysicalEntity:__newindex(key, value)
  if key == "x" then
    self._x = value
    if self._body then self._body:setX(value) end
  elseif key == "y" then
    self._y = value
    if self._body then self._body:setY(value) end
  elseif key == "angle" then
    self._angle = value
    if self._body then self._body:setAngle(value) end
  elseif key == "velx" then
    self._velx = value
    if self._body then self._body:setLinearVelocity(value, self._vely) end
  elseif key == "vely" then
    self._vely = value
    if self._body then self._body:setLinearVelocity(self._velx, value) end
  else
    Entity.__newindex(self, key, value)
  end
end

function PhysicalEntity:initialize(x, y, type)
  Entity.initialize(self)

  -- convert to underscore names so accessors work
  self.x = nil 
  self.y = nil
  self._x = x
  self._y = y

  self._velx = 0
  self._vely = 0
  self._angle = 0
  self.bodyType = type or "static"
end

function PhysicalEntity:update(dt)
  if self._body then
    self._x, self._y = self._body:getPosition()
    self._velx, self._vely = self._body:getLinearVelocity()

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
    self._body = love.physics.newBody(self._world._world, self._x, self._y, type or self.bodyType)
    self._body:setAngle(self._angle)
    self._body:setLinearVelocity(self._velx, self._vely)
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
