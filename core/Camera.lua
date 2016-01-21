Camera = class("Camera")

function Camera:__index(key)
  if key == "x" or key == "y" then
    return self._pos[key]
  else
    return rawget(self, "_" .. key) or self.class.__instanceDict[key]
  end
end

function Camera:__newindex(key, value)
  if key == "x" or key == "y" then
    self._pos[key] = value
    
    if self.bounds then
      if key == "x" then
        self:bindX()
      else
        self:bindY()
      end
    end
  elseif key == "pos" then
    self._pos = value
    if self.bounds then self:bindPosition() end
  else
    rawset(self, key, value)
  end
end

function Camera:initialize(x, y, zoom, angle)
  self._pos = Vector(x or 0, y or 0)
  self.zoom = zoom or 1
  self.angle = angle or 0
end

function Camera:update(dt) end
function Camera:start() end
function Camera:stop() end

function Camera:set(scale)
  scale = scale or 1
  love.graphics.push()
  love.graphics.scale(self.zoom)
  love.graphics.translate(love.graphics.width / self.zoom / 2, love.graphics.height / self.zoom / 2)
  love.graphics.rotate(self.angle)
  love.graphics.translate(-self._pos.x * scale, -self._pos.y * scale)
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:move(dx, dy)
  self.x = self._pos.x + dx -- the _pos shortcut can be used when getting, but not setting
  self.y = self._pos.y + dy
end

function Camera:rotate(dr)
  self.angle = self.angle + dr
end

function Camera:getPosition()
  return self._pos.x, self._pos.y
end

function Camera:setPosition(x, y)
  self.x = x
  self.y = y
end

function Camera:setBounds(x1, y1, x2, y2)
  self.bounds = { x1, y1, x2, y2 }
end

function Camera:bindX()
  self._pos.x = math.clamp(self._pos.x, self.bounds[1] + love.graphics.width / 2 / self.zoom, self.bounds[3] - love.graphics.width / 2 / self.zoom)
end

function Camera:bindY()
  self._pos.y = math.clamp(self._pos.y, self.bounds[2] + love.graphics.height / 2 / self.zoom, self.bounds[4] - love.graphics.height / 2 / self.zoom)
end

function Camera:bindPosition()
  self._pos.x = math.clamp(self._pos.x, self.bounds[1] + love.graphics.width / 2 / self.zoom, self.bounds[3] - love.graphics.width / 2 / self.zoom)
  self._pos.y = math.clamp(self._pos.y, self.bounds[2] + love.graphics.height / 2 / self.zoom, self.bounds[4] - love.graphics.height / 2 / self.zoom)
end
