local function getCoordValue(axis, value)
  if camera.shakeFactor then value = value + camera.shakeFactor end
  
  if camera.bounds then
    return math.clamp(value, camera.bounds[axis .. '1'], camera.bounds[axis .. '2'])
  else
    return value
  end
end

camera = setmetatable({}, {
  __index = function(_, key)
    return (key == 'x' or key == 'y') and camera._pos[key] or rawget(camera, '_' .. key)
  end,
  
  __newindex = function(_, key, value)
    if key == 'x' or key == 'y' then
      camera._pos[key] = getCoordValue(key, value)
    elseif key == 'pos' then
      camera._pos = value
      value.x = getCoordValue('x', value.x)
      value.y = getCoordValue('y', value.y)
    else
      rawset(camera, key, value)
    end
  end
})


Camera = class('Camera')

function Camera:initialize(x, y, zoom, rotation)
  self._pos = Vector(x or 0, y or 0)
  self.zoom = zoom or 1
  self.rotation = rotation or 0
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

function camera:shake(amount)
  camera.shakeFactor = amount
  
  tween(camera, .1, { shakeFactor = -amount }, nil, function()
    tween(camera, .1, { shakeFactor = amount / 2 }, nil, function()
      tween(camera, .1, { shakeFactor = (-amount) / 2 }, nil, function()
        tween(camera, .1, { shakeFactor = amount / 8 }, nil, function()
          tween(camera, .1, { shakeFactor = (-amount) / 8 }, nil, function()
            camera.shakeFactor = nil
          end)
        end)
      end)
    end)
  end)
end
