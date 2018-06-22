Camera = class("Camera")

function Camera:initialize(x, y, zoom, angle)
  self.x = x or love.graphics.width / 2
  self.y = y or love.graphics.height / 2
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
    love.graphics.translate(-self.x * scale, -self.y * scale)
  end
end

function Camera:unset()
  love.graphics.pop()
end

function Camera:move(dx, dy)
  self.x = self.x + dx
  self.y = self.y + dy
end

function Camera:rotate(dr)
  self.angle = self.angle + dr
end

function Camera:getPosition()
  return self.x, self.y
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
  return (x * angcos - y * angsin) + self.x, (x * angsin + y * angcos) + self.y
end

function Camera:screenPosition(worldX, worldY)
  local angcos = cos(-camera.angle)
  local angsin = sin(-camera.angle)
  local x, y = screenX - self.x, screenY - self.y
  x = (x * angcos - y * angsin) * self.zoom
  y = (x * angsin + y * angcos) * self.zoom
  return x + love.graphics.width / 2, y + love.graphics.height / 2
end

function Camera:setBounds(x1, y1, x2, y2)
  self.bounds = { x1, y1, x2, y2 }
end

function Camera:bindX()
  self.x = math.clamp(
    self.x,
    self.bounds[1] + love.graphics.width / 2 / self.zoom,
    self.bounds[3] - love.graphics.width / 2 / self.zoom
  )
end

function Camera:bindY()
  self.y = math.clamp(
    self.y,
    self.bounds[2] + love.graphics.height / 2 / self.zoom,
    self.bounds[4] - love.graphics.height / 2 / self.zoom
  )
end

function Camera:bind()
  self:bindX()
  self:bindY()
end
