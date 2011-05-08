Entity = class('Entity')

-- METATABLE --

Entity._mt = {}

function Entity._mt:__index(key)
  local result = rawget(self, '_' .. key) or self.class.__classDict[key]

  if result then
    return result
  elseif key == 'x' or key == 'y' then
    return self._pos[key]
  end
end

function Entity._mt:__newindex(key, value)
  if key == 'x' or key == 'y' then
    self._pos[key] = value    
  elseif key == 'layer' then
    if self._layer == value then return end
    
    if self._world then
      local prev = self._layer
      self._layer = value
      self._world:_setLayer(self, prev)
    else
      self._layer = value
    end
  elseif key == 'world' then
    if self._world == value then return end
    if self._world then self._world:remove(self) end
    if value then value:add(self) end
  else
    rawset(self, key, value)
  end
end

Entity:enableAccessors()

-- METHODS --

function Entity:initialize(t)
  -- position/dimensions
  self._pos = Vector(0, 0)
  self.width = 0
  self.height = 0
  self.originX = 0
  self.originY = 0
  self.collidable = true
  
  -- settings
  self.active = true
  self.visible = true
  
  -- private stuff
  self._layer = 1
  
  -- Entities will also have the following properties once added to a world:
  -- self._world
  -- self._updateNext
  -- self._updatePrev
  -- self._drawNext
  -- self._drawPrev
  
  self:applyAccessors()
  
  if t then
    for k, v in pairs(t) do
      self[k] = v
    end
  end
end

function Entity:update(dt) end
function Entity:draw() end
function Entity:added() end
function Entity:removed() end

function Entity:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function Entity:animate(duration, t)
  if not self._world then return end
  
  local ease = t.ease
  local onComplete = t.onComplete
  t.ease = nil
  t.onComplete = nil
  
  local tween = AttrTween:new(self, duration, t, Tween.ONESHOT, onComplete, ease)
  self._world:add(tween)
  return tween:start()
end

function Entity:collides(with, ...)
  args = {...}
  
  if type(with) == 'number' then
    local px = with
    local py = args[1]
    local x = args[2] or self.x
    local y = args[3] or self.y
    
    return px >= x - self.originX and px < x - self.originX + self.width
       and py >= y - self.originY and py < y - self.originY + self.height
  elseif instanceOf(Entity, with) then
    local x = args[1] or self.x
    local y = args[2] or self.y
    
    return x - self.originX + self.width > with.x + with.originX
       and x - self.originX < with.x - with.originX + with.width
       and y - self.originY + self.height > with.y + with.originY
       and y - self.originY < with.y - with.originY + with.height
  end
  
  return false
end

-- distanceTo
-- distanceToPoint
-- distanceToRect

function Entity:getPosition()
  return self.x, self.y
end

function Entity:setPosition(x, y)
  if x then self.x = x end
  if y then self.y = y end
end

function Entity:getSize()
  return self.width, self.height
end

function Entity:setSize(width, height)
  if width then self.width = width end
  if height then self.height = height end
end
