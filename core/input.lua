-- METATABLE --

local mt = {
  __index = function(t, key)
    if key == 'any' then return t.count > 0 end
  end
}

-- INPUT --

input = {}
input._maps = {}

function input.define(t, ...)
  if type(t) == 'string' then
    input._maps[t] = { key = {...} }
  else
    if type(t.key) == 'string' then t.key = { t.key } end
    if type(t.mouse) == 'string' then t.mouse = { t.mouse } end
    input._maps[t[1]] = t
  end
end

function input.pressed(name)
  return input._check(name, 'pressed')
end

function input.down(name)
  return input._check(name, 'down')
end

function input.released(name)
  return input._check(name, 'released')
end

function input._check(name, type)
  local map = input._maps[name]
  
  if map.key then
    for _, v in pairs(map.key) do
      if key[type][v] then return true end
    end
  end
  
  if map.mouse then
    for _, v in pairs(map.mouse) do
      if mouse[type][v] then return true end
    end
  end
  
  return false
end

function input._event(e, a, b, c)
  if e == 'kp' then
    key.pressed[a] = true
    key.down[a] = true
    key.pressed.count = key.pressed.count + 1
    key.down.count = key.down.count + 1
  elseif e == 'kr' then
    key.released[a] = true
    key.down[a] = nil
    key.released.count = key.released.count + 1
    key.down.count = key.down.count - 1
  elseif e == 'mp' then
    mouse.pressed[c] = true
    mouse.down[c] = true
    mouse.pressed.count = mouse.pressed.count + 1
    mouse.down.count = mouse.down.count + 1
  elseif e == 'mr' then
    mouse.released[c] = true
    mouse.down[c] = nil
    mouse.released.count = mouse.released.count + 1
    mouse.down.count = mouse.down.count - 1
  end
end

function input._update()
  key.pressed = setmetatable({ count = 0 }, mt)
  key.released = setmetatable({ count = 0 }, mt)
  mouse.pressed = setmetatable({ count = 0 }, mt)
  mouse.released = setmetatable({ count = 0 }, mt)
  mouse.x = love.mouse.getX()
  mouse.y = love.mouse.getY()
end

-- KEY AND MOUSE --

key = {}
mouse = {}

for _, v in pairs{'pressed', 'down', 'released'} do
  key[v] = setmetatable({ count = 0 }, mt)
  mouse[v] = setmetatable({ count = 0 }, mt)
end
