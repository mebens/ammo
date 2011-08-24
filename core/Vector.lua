-- based on hump.vector
Vector = class('Vector')

function Vector:initialize(x, y)
  if type(x) == 'table' then
    self.x = x[1]
    self.y = x[2]
  else
    self.x = x
    self.y = y
  end
end

function Vector:unpack()
  return self.x, self.y
end

function Vector:set(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function Vector:normalize()
  local l = self:len()
  self.x, self.y = self.x / l, self.y / l
  return self
end

function Vector:normalized()
  return self / self:len()
end

function Vector:rotate(phi)
  local c, s = math.cos(phi), math.sin(phi)
  self.x = c * self.x - s * self.y
  self.y = s * self.x + c * self.y
  return self
end

function Vector:rotated(phi)
  return Vector(self.x, self.y):rotate(phi)
end

function Vector:perpendicular()
  return Vector(-self.y, self.x)
end

function Vector:projectOn(v)
  return (self * v) * v / v:lenSq()
end

function Vector:cross(other)
  return self.x * other.y - self.y * other.x
end

function Vector:lenSq()
  return self * self
end

function Vector:len()
  return math.sqrt(self * self)
end

function Vector:__tostring()
  return '(' .. self.x .. ',' .. self.y ..')'
end

function Vector.__unm(a)
  return Vector(-a.x, -a.y)
end

function Vector.__add(a, b)
  if type(a) == 'number' then
    return Vector(a + b.x, a + b.y)
  elseif type(b) == 'number' then
    return Vector(b + a.x, b + a.y)
  else
    return Vector(a.x + b.x, a.y + b.y)
  end
end

function Vector.__sub(a, b)
  if type(a) == 'number' then
    return Vector(a - b.x, a - b.y)
  elseif type(b) == 'number' then
    return Vector(b - a.x, b - a.y)
  else
    return Vector(a.x - b.x, a.y - b.y)
  end
end

function Vector.__mul(a, b)
  if type(a) == "number" then
    return Vector(a * b.x, a * b.y)
  elseif type(b) == "number" then
    return Vector(b * a.x, b * a.y)
  else
    return a.x * b.x + a.y * b.y
  end
end

function Vector.__div(a, b)
  return Vector(a.x / b, a.y / b)
end

function Vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

function Vector.__lt(a, b)
  return a.x < b.x or (a.x == b.x and a.y < b.y)
end

function Vector.__le(a, b)
  return a.x <= b.x and a.y <= b.y
end

function Vector.permul(a, b)
  return Vector(a.x * b.x, a.y * b.y)
end

function Vector.dist(a, b)
  return (b - a):len()
end
