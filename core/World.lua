World = class('World')
World._mt = {}

function World._mt:__index(key)
  if key == 'count' then
    return self._updates._length
  elseif key == 'all' then
    return self._updates:getAll()
  else
    return self.class.__classDict[key]
  end
end

function World:initialize(t)
  -- settings
  self.active = true
  self.visible = true
  
  -- lists
  self._updates = SpecialLinkedList:new('_updateNext', '_updatePrev')
  self._updateFilters = {}
  self._drawFilters = {}
  self._layers = {}
  self._add = {}
  self._remove = {}
  self._classCounts = {}
 
  self:applyAccessors()
  
  if t then
    for k, v in pairs(t) do
      self[k] = v
    end
  end
end

function World:update(dt)
  -- update
  for v in self._updates:getIterator() do
    if v.active then
      v:update(dt)
      
      for _, filter in pairs(self._updateFilters) do
        filter:updateFilter(v, dt)
      end
    end
  end
  
  -- remove
  for _, v in pairs(self._remove) do
    if v.removed then v:removed() end
    self._updates:remove(v)    
    v._world = nil
    self._classCounts[v.class.name] = self._classCounts[v.class.name] - 1
    
    if v._layer then
      self._layers[v._layer]:remove(v)
    end
  end
  
  -- add
  for _, v in pairs(self._add) do
    self._updates:push(v)
    v._world = self
    self._classCounts[v.class.name] = (self._classCounts[v.class.name] or 0) + 1
    
    if v._layer then self:_setLayer(v) end
    if v.added then v:added() end
  end
  
  -- empty tables
  self._add = {}
  self._remove = {}
end

function World:draw()
  for i = #self._layers, 1, -1 do
    if self._layers[i] then
      for v in self._layers[i]:getIterator(true) do -- reverse
        if v.visible then
          if v.color then love.graphics.pushColor(v.color) end
          v:draw()
          if v.color then love.graphics.popColor() end
        end
        
        -- we should apply draw filters even if the actually entity isn't visible
        for _, filter in pairs(self._drawFilters) do
          filter:drawFilter(v)
        end
      end
    end
  end
end

function World:start() end
function World:stop() end

function World:add(...)
  for _, v in pairs{...} do
    if not v._world then
      self._add[#self._add + 1] = v
    end
  end
end

function World:remove(...)
  for _, v in pairs{...} do
    if v._world == self then
      self._remove[#self._remove + 1] = v
    end
  end
end

function World:removeAll(entitiesOnly)
  if entitiesOnly then
    for e in self._updates:getIterator() do
      if instanceOf(Entity, e) then
        self._remove[#self._remove + 1] = v
      end
    end
  else
    for e in self._updates:getIterator() do
      self._remove[#self._remove + 1] = v
    end
  end
end

function World:addFilter(filter, type)
  if type ~= 'draw' then self._updateFilters[#self._updateFilters + 1] = filter end
  if type ~= 'update' then self._drawFilters[#self._drawFilters + 1] = filter end
end

function World:classCount(cls)
  if type(cls) == 'table' then cls = cls.name end
  return self._classCounts[cls]
end

-- isAt*
-- send|bring*
-- nearest*

function World:getIterator()
  return self._updates:getIterator()
end

function World:_setLayer(e, prev)
  if self._layers[prev] then self._layers[prev]:remove(e) end

  if not self._layers[e._layer] then
    self._layers[e._layer] = SpecialLinkedList:new('_drawNext', '_drawPrev')
  end
  
  self._layers[e._layer]:push(e)
end
