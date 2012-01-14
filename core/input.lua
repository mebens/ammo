-- METATABLE --

local mt = {
  __index = function(t, key)
    if key == 'any' then return t.count > 0 end
  end
}

-- INPUT --

t = {}
t._maps = {}

function t.define(t, ...)
  if type(t) == 'string' then
    t._maps[t] = { key = {...} }
  else
    if type(t.key) == 'string' then t.key = { t.key } end
    if type(t.mouse) == 'string' then t.mouse = { t.mouse } end
    t._maps[t[1]] = t
  end
end

function t.pressed(name)
  return t._check(name, 'pressed')
end

function t.down(name)
  return t._check(name, 'down')
end

function t.released(name)
  return t._check(name, 'released')
end

function t._check(name, type)
  local map = t._maps[name]
  
  if map.key then
    for _, v in pairs(map.key) do
      if t.key[type][v] then return true end
    end
  end
  
  if map.mouse then
    for _, v in pairs(map.mouse) do
      if t.mouse[type][v] then return true end
    end
  end
  
  return false
end

function t._event(e, a, b, c)  
  if e == 'kp' then
    local k = t.key
    k.pressed[a] = true
    k.down[a] = true
    k.pressed.count = k.pressed.count + 1
    k.down.count = k.down.count + 1
  elseif e == 'kr' then
    local k = t.key
    k.released[a] = true
    k.down[a] = nil
    k.released.count = k.released.count + 1
    k.down.count = k.down.count - 1
  elseif e == 'mp' then
    local m = t.mouse
    m.pressed[c] = true
    m.down[c] = true
    m.pressed.count = m.pressed.count + 1
    m.down.count = m.down.count + 1
  elseif e == 'mr' then
    local m = t.mouse
    m.released[c] = true
    m.down[c] = nil
    m.released.count = m.released.count + 1
    m.down.count = m.down.count - 1
  end
end

function t._update()
  t.key.pressed = setmetatable({ count = 0 }, mt)
  t.key.released = setmetatable({ count = 0 }, mt)
  t.mouse.pressed = setmetatable({ count = 0 }, mt)
  t.mouse.released = setmetatable({ count = 0 }, mt)
  t.mouse.x = love.mouse.getX()
  t.mouse.y = love.mouse.getY()
end

-- KEY AND MOUSE --

t.key = {}
t.mouse = {}

for _, v in pairs{'pressed', 'down', 'released'} do
  t.key[v] = setmetatable({ count = 0 }, mt)
  t.mouse[v] = setmetatable({ count = 0 }, mt)
end

return t
