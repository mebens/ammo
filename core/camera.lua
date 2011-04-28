Camera = class('Camera')
Camera._mt = {}

function Camera._mt:__index(key)
  return (key == 'x' or key == 'y') and self._pos[key] or rawget(self, '_' .. key)
end
  
function Camera._mt:__newindex(key, value)
  if key == 'x' or key == 'y' then
    self._pos[key] = self:_getCoordValue(key, value)
  elseif key == 'pos' then
    self._pos = value
    value.x = self:_getCoordValue('x', value.x)
    value.y = self:_getCoordValue('y', value.y)
  else
    rawset(self, key, value)
  end
end

function Camera:initialize(x, y, zoom, rotation)
  self._pos = Vector(x or 0, y or 0)
  self.zoom = zoom or 1
  self.rotation = rotation or 0
  self:applyAccessors()
end

function Camera:set()
  love.graphics.push()
  love.graphics.scale(self.zoom)
  love.graphics.rotate(self.rotation)
  love.graphics.translate(-self.x, -self.y)
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function Camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function Camera:getPosition()
  return self.x, self.y
end

function Camera:setPosition(x, y)
  self.x = x
  self.y = y
end

function Camera:setBounds(x1, y1, x2, y2)
  self.bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function Camera:_getCoordValue(axis, value)
  if self.bounds then
    return math.clamp(value, self.bounds[axis .. '1'], self.bounds[axis .. '2'])
  else
    return value
  end
end
