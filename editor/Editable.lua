Editable = {}

function Editable:included(world)
  world:addFilter(Filter:new(), 'draw')
  
  world._gui = {}
  -- add GUI elements
  for _, v in pairs(world._gui) do v._editor = true end
end

function Editable:update(dt)
  for _, v in pairs(self._gui) do
    if v.active then v:update(dt) end
  end
  
  self:_updateLists()
end
