Entity = class("Entity")

function Entity:__index(key)
  return rawget(self, "_" .. key) or self.class.__instanceDict[key]
end

function Entity:__newindex(key, value)
  if key == "layer" then
    if self._layer == value then return end
    
    if self._world then
      local prev = self._layer
      self._layer = value
      self._world:_setLayer(self, prev)
    else
      self._layer = value
    end
  elseif key == "world" then
    if self._world == value then return end
    if self._world then self._world:remove(self) end
    if value then value:add(self) end
  else
    rawset(self, key, value)
  end
end

function Entity:initialize(x, y)
  self.x = x or 0
  self.y = y or 0
  self.active = true
  self.visible = true
  self._layer = 1
end

function Entity:added() end
function Entity:update(dt) end
function Entity:draw() end
function Entity:removed() end
