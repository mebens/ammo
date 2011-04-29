-- INPUT --

input = {}
input._maps = {}

function input.define(t)
  input._maps[t[1]] = t
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
  elseif e == 'kr' then
    key.released[a] = true
    key.down[a] = nil
  elseif e == 'mp' then
    mouse.pressed[c] = true
    mouse.down[c] = true
  elseif e == 'mr' then
    mouse.released[c] = true
    mouse.down[c] = nil
  end
end

function input._update()
  key.pressed = {}
  key.released = {}
  mouse.pressed = {}
  mouse.released = {}
end

-- KEY --

key = {}
key.pressed = {}
key.down = {}
key.released = {}

-- MOUSE --

mouse = {}
mouse.pressed = {}
mouse.released = {}
mouse.down = {}
