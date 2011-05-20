List = class('List', Control)

function List:initialize(x, y, width, cellHeight)
  Control.initialize(self, x, y)
  self.width = width
  self.cellPadding = 5
  self.color = table.copy(self.style.medBg)
  self._cellHeight = cellHeight
  self._cells = cells
  self._items = {}
end

function List:draw()
  if #self._items == 0 then return end
  local ax = self.absX
  local ay = self.absY
  self:drawBorder(self.style.border)
  
  for i, v in ipairs(self._items) do
    if i > 1 then
      local lineY = (i - 1) * (self._cellHeight + 1)
      love.graphics.pushColor(self.style.border)
      love.graphics.line(ax, lineY, ax + self.width, lineY)
      love.graphics.popColor()
    end
    
    love.graphics.rectangle("fill", ax, ay + (i - 1) * (self._cellHeight + 2))
  end
end

function List:insert(item, at)
  assert(type(item) == 'table', "Item must be a table")
  if #self._items >= self._cells then return end

  if at then
    table.insert(self._items, at, item)
  else
    table.insert(self._items, item)
  end
  
  self.height = math.ceil(#self._items / self._cellHeight)
end

function List:delete(at)
  if at then
    table.remove(self._items, at)
  else
    table.remove(self._items)
  end
  
  self.height = math.ceil(#self._items / self._cellHeight)
end
