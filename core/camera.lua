local t = setmetatable({}, {
  __index = function(self, key)
    return (key == "x" or key == "y") and self._pos[key] or rawget(self, "_" .. key)
  end,
  
  __newindex = function(self, key, value)
    if key == "x" or key == "y" then
      self._pos[key] = self.processCoordinate(key, value)
    elseif key == "pos" then
      self._pos = value
      value.x = self.processCoordinate("x", value.x)
      value.y = self.processCoordinate("y", value.y)
    else
      rawset(self, key, value)
    end
  end
})

t._pos = Vector(0, 0)
t.zoom = 1
t.rotation = 0

function t.set(scale)
  scale = scale or 1
  love.graphics.push()
  love.graphics.scale(t.zoom)
  love.graphics.rotate(t.rotation)
  love.graphics.translate(-t.x * scale, -t.y * scale)
end

function t.unset()
  love.graphics.pop()
end

function t.move(dx, dy)
  t.x = t.x + dx
  t.y = t.y + dy
end

function t.rotate(dr)
  t.rotation = t.rotation + dr
end

function t.getPosition()
  return t.x, t.y
end

function t.setPosition(x, y)
  t.x = x
  t.y = y
end

function t.setBounds(x1, y1, x2, y2)
  t.bounds = { x1 = x1, y1 = y1, x2 = x2, y2 = y2 }
end

function t.processCoordinate(axis, value)
  return t.bounds and math.clamp(value, t.bounds[axis .. "1"], t.bounds[axis .. "2"]) or value
end

return t
