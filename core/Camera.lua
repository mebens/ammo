Camera = class("Camera")

function Camera:__index(key)
  return rawget(self, "_" .. key) or self.class.__instanceDict[key]
end

function Camera:__newindex(key, value)
  if key == "x" then
    self.transform:translate(-(x - self._x), 0)
    self._x = value
  elseif key == "y" then
    self.transform:translate(0, -(y - self._y))
    self._y = value
  elseif key == "zoom" then
    self.transform:scale(value / self._zoom)
    self._zoom = value
  elseif key == "angle" then
    self.transform:rotate(value - self._angle)
    self._angle = value
  else
    rawset(self, key, value)
  end
end

function Camera:initialize(x, y, zoom, angle)
  self._x = x or 0
  self._y = y or 0
  self._zoom = zoom or 1
  self._angle = angle or 0
  self._lscale = 1

  self.transform = love.math.newTransform(love.graphics.width / 2, love.graphics.height / 2)
  self.transform:scale(self.zoom):rotate(self.rotate):translate(-x, -y)
end

function Camera:update(dt) end
function Camera:start() end
function Camera:stop() end

function Camera:set(scale)
  scale = scale or 1
  
  -- allows parallax layering
  if scale ~= 1 then
    self._lscale = scale
    self.transform:translate((self._x * scale) - self._x, (self._y * scale) - self._y)
  end

  love.graphics.push()
end

function Camera:unset()
  if self._lscale ~= 1 then
    self.transform:translate(self._x - (self._x * self._lscale), self._y - (self._y * self._lscale))
    self._lscale = 1
  end

  love.graphics.pop()
end

function Camera:move(dx, dy)
  self.transform:translate(-dx, -dy)
end

function Camera:rotate(dr)
  self.transform:rotate(dr)
end

function Camera:getPosition()
  return self._x, self._y
end

function Camera:setPosition(x, y)
  self.transform:translate(-(x - self._x), -(y - self._y))
  self._x = 0
  self._y = 0
end

function Camera:worldPosition(screenX, screenY)
  return self.transform:inverseTransformPoint(screenX, screenY)
end

function Camera:screenPosition(worldX, worldY)
  return self.transform:transformPoint(worldX, worldY)
end

function Camera:setBounds(x1, y1, x2, y2)
  self.bounds = { x1, y1, x2, y2 }
end

function Camera:bindX()
  self.x = math.clamp(
    self._x,
    self.bounds[1] + love.graphics.width / 2 / self.zoom,
    self.bounds[3] - love.graphics.width / 2 / self.zoom
  )
end

function Camera:bindY()
  self.y = math.clamp(
    self._y,
    self.bounds[2] + love.graphics.height / 2 / self.zoom,
    self.bounds[4] - love.graphics.height / 2 / self.zoom
  )
end

function Camera:bind()
  self:bindX()
  self:bindY()
end
