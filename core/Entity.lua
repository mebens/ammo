Entity = class("Entity")

-- METATABLE --

Entity._mt = {}

function Entity._mt:__index(key)
  local result = rawget(self, "_" .. key) or self.class.__instanceDict[key]

  if result then
    return result
  elseif key == "x" or key == "y" then
    return self._pos[key]
  elseif key == "absX" then
    return self._pos.x + (self._parent and self._parent.absX or 0)
  elseif key == "absY" then
    return self._pos.y + (self._parent and self._parent.absY or 0) 
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
      local prev = self._name
      self._name = value
      self._world:_setName(self, prev)
    else
      self._name = value
    end
  elseif key == "world" then
    if self._world == value then return end
    if self._world then self._world:remove(self) end
    if value then value:add(self) end
  elseif key == "parent" then
    value:add(self)
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

function Entity:added()
  if self._children then
    for v in self._children:getIterator() do self._world:add(v) end
  end
end

function Entity:update(dt) end
function Entity:draw() end
function Entity:removed() end

function Entity:add(...)
  if not self._children then
    self._children = LinkedList:new("_childNext", "_childPrev")
  end
  
  for _, v in pairs{...} do
    if self._world then self._world:add(v) end
    self._children:push(v)
    v._parent = self
  end
end

function Entity:remove(...)
  if not self._children then return end
  
  for _, v in pairs{...} do
    if v._parent == self then
      if self._world then self._world:remove(v) end
      self._children:remove(v)
      v._parent = nil
    end
  end
end

function Entity:removeAll()
  if not self._children then return end
  for v in self._children:getIterator() do self:remove(v) end
end

function Entity:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function Entity:getPosition()
  return self.x, self.y
end

function Entity:setPosition(x, y)
  if x then self.x = x end
  if y then self.y = y end
end

function Entity:absPosition()
  return self.absX, self.absY
end

function Entity:getSize()
  return self.width, self.height
end

function Entity:setSize(width, height)
  if width then self.width = width end
  if height then self.height = height end
end
