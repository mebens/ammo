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
  elseif key == "pos" then
    self._pos = value
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
  local xCentre = love.graphics.width / self.zoom / 2
  local yCentre = love.graphics.height / self.zoom / 2
  
  love.graphics.push()
  love.graphics.scale(self.zoom)
  love.graphics.translate(xCentre, yCentre)
  love.graphics.rotate(self.angle)
  
  if scale == 0 then
    love.graphics.translate(-xCentre, -yCentre)
  else
    love.graphics.translate(-self._pos.x * scale, -self._pos.y * scale)
  end
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

-- for speed
local cos = math.cos
local sin = math.sin

function Camera:worldPosition(screenX, screenY)
  local angcos = cos(-self.angle)
  local angsin = sin(-self.angle)
  local x = (screenX - love.graphics.width / 2) / self.zoom
  local y = (screenY - love.graphics.height / 2) / self.zoom
  return (x * angcos - y * angsin) + self._pos.x, (x * angsin + y * angcos) + self._pos.y
end

function Camera:screenPosition(worldX, worldY)
  local angcos = cos(-camera.angle)
  local angsin = sin(-camera.angle)
  local x, y = screenX - self._pos.x, screenY - self._pos.y
  x = (x * angcos - y * angsin) * self.zoom
  y = (x * angsin + y * angcos) * self.zoom
  return x + love.graphics.width / 2, y + love.graphics.height / 2
end

function Camera:setBounds(x1, y1, x2, y2)
  self.bounds = { x1, y1, x2, y2 }
end

function Camera:bindX()
  self._pos.x = math.clamp(
    self._pos.x,
    self.bounds[1] + love.graphics.width / 2 / self.zoom,
    self.bounds[3] - love.graphics.width / 2 / self.zoom
  )
end

function Camera:bindY()
  self._pos.y = math.clamp(
    self._pos.y,
    self.bounds[2] + love.graphics.height / 2 / self.zoom,
    self.bounds[4] - love.graphics.height / 2 / self.zoom
  )
end

function Camera:bind()
  self:bindX()
  self:bindY()
end
