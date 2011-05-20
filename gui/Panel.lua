Panel = class('Panel', Control)
Panel._mt = {}

function Panel._mt:__newindex(key, value)
  if key == 'title' then
    self._title = value
    self._titleWidth = self.style.fontSmall:getWidth(value)
  else
    Entity._mt.__newindex(self, key, value)
  end
end

Panel:enableAccessors()

function Panel:initialize(x, y, width, height, title)
  Control.initialize(self, x, y)
  self.width = width
  self.height = height
  self.showTitleBar = true
  self.titleBarPadding = 5
  self.titleBarSize = self.style.fontSmall:getHeight() + self.titleBarPadding * 2
  self.color = table.copy(self.style.darkBg)
  self.titleColor = table.copy(self.style.lightBg)
  self.draggable = true
  
  self:applyAccessors()
  self.title = title
end

function Panel:draw()
  local ax = self.absX
  local ay = self.absY
  love.graphics.rectangle("fill", ax, ay, self.width, self.height)
  
  if self.showTitleBar then
    love.graphics.pushColor(self.titleColor)
    love.graphics.rectangle("fill", ax, ay, self.width, self.titleBarSize)
    love.graphics.popColor()
    
    love.graphics.pushColor(self.style.darkText)
    love.graphics.print(self._title, ax + math.max(math.floor(self.width / 2 - self._titleWidth / 2), self.titleBarPadding), ay + self.titleBarPadding)
    love.graphics.popColor()
  end
end

function Panel:mouseDown(x, y)
  if y <= self.absY + self.titleBarSize then Control.mouseDown(self, x, y) end
end
