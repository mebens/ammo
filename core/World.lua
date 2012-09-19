World = class("World")
World._mt = {}

function World._mt:__index(key)
  if key == "count" then
    return self._updates._length
  elseif key == "all" then
    return self._updates:getAll()
  else
    return self.class.__instanceDict[key]
  end
end

World:enableAccessors()

function World:initialize()
  -- settings
  self.active = true
  self.visible = true
  
  -- lists
  self._updates = LinkedList:new("_updateNext", "_updatePrev")
  self._layers = { min = 0, max = 0 }
  self._updateFilters = {}
  self._drawFilters = {}
  self._add = {}
  self._remove = {}
  self._classCounts = {}
  self.names = {}
  
  self:applyAccessors()
end

function World:update(dt)
  -- update
  for v in self._updates:getIterator() do
    if v.active then
      v:update(dt)
      for _, filter in pairs(self._updateFilters) do filter(v, dt) end
    end
  end
  
  self:_updateLists()
end

function World:draw()  
  for i = self._layers.max, self._layers.min, -1 do
    local layer = self._layers[i]
    
    if layer then
      ammo.camera:set(layer.scale)
      
      for v in layer:getIterator(true) do -- reverse
        if v.visible then v:draw() end
        for _, filter in pairs(self._drawFilters) do filter(v) end -- we should apply draw filters even if the actually entity isn't visible
      end
      
      ammo.camera:unset()
    end
  end
end

function World:start() end
function World:stop() end

function World:add(...)
  for _, v in pairs{...} do
    if not v._world then self._add[#self._add + 1] = v end
  end
end

function World:remove(...)
  for _, v in pairs{...} do
    if v._world == self and not v._removalQueued then
      self._remove[#self._remove + 1] = v
      v._removalQueued = true
    end
  end
end

function World:removeAll(entitiesOnly)
  if entitiesOnly then
    for e in self._updates:getIterator() do
      if instanceOf(Entity, e) then
        self._remove[#self._remove + 1] = v
        v._removalQueued = true
      end
    end
  else
    for e in self._updates:getIterator() do
      self._remove[#self._remove + 1] = v
      v._removeQueued = true
    end
  end
end

function World:addUpdateFilter(func)
  self._updateFilters[#self._updateFilters + 1] = func
end

function World:addDrawFilter(func)
  self._drawFilters[#self._drawFilters + 1] = func
end

function World:addLayer(index, scale)
  local layer = LinkedList:new("_drawNext", "_drawPrev")
  layer._scale = scale or 1
  self._layers[index] = layer
  self._layers.min = math.min(index, self._layers.min)
  self._layers.max = math.max(index, self._layers.max)
  return layer
end

function World:setupLayers(t)
  for k, v in pairs(t) do self:addLayer(k, v) end
end

function World:classCount(cls)
  if type(cls) == "table" then cls = cls.name end
  return self._classCounts[cls]
end

-- isAt*
-- send|bring*
-- nearest*

function World:getIterator()
  return self._updates:getIterator()
end

function World:_updateLists()
  -- remove
  for _, v in pairs(self._remove) do
    if v.removed then v:removed() end
    self._updates:remove(v)
    v._removalQueued = false
    v._world = nil
    if v.class then self._classCounts[v.class.name] = self._classCounts[v.class.name] - 1 end
    if v.layer then self._layers[v._layer]:remove(v) end
    if v.name then self.names[v.name] = nil end 
  end
  
  -- add
  for _, v in pairs(self._add) do
    self._updates:push(v)
    v._world = self
    if v.class then self._classCounts[v.class.name] = (self._classCounts[v.class.name] or 0) + 1 end
    if v.layer then self:_setLayer(v) end
    if v.name then self:_setName(v) end
    if v.added then v:added() end
  end
  
  -- empty tables
  self._add = {}
  self._remove = {}
end

function World:_setLayer(e, prev)
  if self._layers[prev] then self._layers[prev]:remove(e) end
  if not self._layers[e.layer] then self:addLayer(e.layer) end
  self._layers[e.layer]:unshift(e)
end

function World:_setName(e, prev)
  assert(not self.names[e.name], "An entity already has the name \"" .. e.name .. "\" in this world.")
  if prev then self.names[prev] = nil end
  self.names[e.name] = e
end
