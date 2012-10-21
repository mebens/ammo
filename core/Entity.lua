Entity = class("Entity")

-- METATABLE --

Entity._mt = {}

function Entity._mt:__index(key)
  if key == "x" or key == "y" then
    return self._pos[key]
  else
    return rawget(self, "_" .. key) or self.class.__instanceDict[key]
  end
end

function Entity._mt:__newindex(key, value)
  if key == "x" or key == "y" then
    self._pos[key] = value
  elseif key == "layer" then
    if self._layer == value then return end
    
    if self._world then
      local prev = self._layer
      self._layer = value
      self._world:_setLayer(self, prev)
    else
      self._layer = value
    end
  elseif key == "name" then
    if self._name == value then return end
    
    if self._world then
      if self._name then self._world.names[self._name] = nil end
      self._world.names[value] = self
    else
      self._name = value
    end
  elseif key == "world" then
    if self._world == value then return end
    if self._world then self._world:remove(self) end
    if value then value:add(self) end
  else
    rawset(self, key, value)
  end
end

Entity:enableAccessors()

-- METHODS --

function Entity:initialize(x, y, width, height)
  self._pos = Vector(x or 0, y or 0)
  self.collidable = true
  self.active = true
  self.visible = true
  self._layer = 1  
  if width or not self.width then self.width = width or 0 end
  if height or not self.height then self.height = height or 0 end
  self:applyAccessors()
end

function Entity:added() end
function Entity:update(dt) end
function Entity:draw() end
function Entity:removed() end

function Entity:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function Entity:getPosition()
  return self.x, self.y
end

function Entity:setPosition(x, y)
  self.x = x
  self.y = y
end

function Entity:getSize()
  return self.width, self.height
end

function Entity:setSize(width, height)
  self.width = width
  self.height = height
end
