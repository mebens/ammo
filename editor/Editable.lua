Editable = {}

function Editable:included(world)
  world:addFilter(Filter:new(), 'draw')
  
  for e in world:getIterator() do
    if instanceOf(Entity, e) then e:include(MouseInteractive) end
  end
  
  function world:add(...)
    for _, v in pairs{...} do
      if not v._world then
        self._add[#self._add + 1] = v
        if instanceOf(Entity, v) then v:include(MouseInteractive) end
      end
    end
  end
  
  world._gui = {}
  -- add GUI elements
  for _, v in pairs(world._gui) do v._editor = true end
end

function Editable:update(dt)
  for v in self._updates:getIterator() do
    if v.active then
      if v._editor then v:update(dt) end
      if v.updateMouse then v:updateMouse() end
    end
  end
  
  self:_updateLists()
end
