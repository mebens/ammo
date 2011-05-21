List = class('List', Control)
List._mt = {}

function List._mt:__newindex(key, value)
  if key == 'selected' then
    if self._selected then tween(self._selected._color, .15, self.style.medBg) end
    self._selected = value
    
    if value then
      tween(value._color, .15, self.style.medActiveBg)
      if self.onSelect then self:onSelect(item) end
    elseif self.onDeselect then
      self:onDeselect()
    end
  else
    Entity._mt.__newindex(self, key, value)
  end
end

List:enableAccessors()

function List:initialize(x, y, width, cellHeight)
  Control.initialize(self, x, y)
  self.width = width
  self.cellPadding = 5
  self._cellHeight = cellHeight
  self._items = {}
  self:applyAccessors()
end

function List:draw()
  if #self._items == 0 then return end
  local ax = self.absX
  local ay = self.absY
  self:drawBorder(self.style.border)
  
  for i, v in ipairs(self._items) do
    local yPos = ay + (i - 1) * (self._cellHeight + 1)
    
    if i > 1 then
      love.graphics.pushColor(self.style.border)
      love.graphics.line(ax, yPos, ax + self.width, yPos)
      love.graphics.popColor()
    end
    
    love.graphics.pushColor(v._color)
    love.graphics.rectangle("fill", ax, yPos + 1, self.width, self._cellHeight)
    love.graphics.popColor()
    
    if v.text then
      love.graphics.pushColor(self.style.text)
      love.graphics.print(v.text, ax + math.max(math.floor(self.width / 2 - v._textWidth / 2), self.cellPadding), yPos + 1 + self.cellPadding)
      love.graphics.popColor()
    end
    
    -- TODO: images
  end
end

function List:insert(item, at)
  assert(type(item) == 'table', "Item must be a table")
  item._color = table.copy(self.style.medBg)
  if item.text then item._textWidth = self.style.fontSmall:getWidth(item.text) end
  
  if at then
    table.insert(self._items, at, item)
  else
    table.insert(self._items, item)
  end
  
  self.height = math.ceil(#self._items * self._cellHeight)
end

function List:delete(at)
  if at then
    table.remove(self._items, at)
  else
    table.remove(self._items)
  end
  
  self.height = math.ceil(#self._items * self._cellHeight)
end

function List:mouseDown(x, y)
  Control.mouseDown(self, x, y)
  
  if mouse.pressed.l then
    local item = self._items[math.ceil((y - self.absY) / self._cellHeight)]
    if item then self.selected = item end
  end
end
