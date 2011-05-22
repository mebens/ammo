-- relies on strong's insert method
-- TODO multiline

TextInput = class('TextInput', Control)
TextInput._mt = {}

function TextInput._mt:__newindex(key, value)
  if key == 'cursor' then
    self._cursor = math.clamp(value, 1, #self.text + 1)
  elseif key == 'selection' and self._cursor + value > 0 and self._cursor + value <= #self.text then
    self._selection = value
  else
    Entity._mt.__newindex(self, key, value)
  end
end

TextInput:enableAccessors()

function TextInput:initialize(x, y, width, rows)
  Control.initialize(self, x, y)
  
  -- private/needed properties
  self.padding = 3
  self._rows = rows or 1
  self._fontHeight = self.style.fontSmall:getHeight()
  self._cursor = 1
  self._selection = 0
  
  -- dimensions/text/settings
  self.width = width
  self.height = self._fontHeight * self._rows + self.padding * 2
  self.text = ""
  self.editable = true
  self.blinkDelay = .5
  
  -- colors
  self.color = table.copy(self.style.medBg)
  self.cursorColor = table.copy(self.style.darkBg)
  self.cursorColor[4] = 255
  
  -- other setup calls
  self:applyAccessors()
  self:_tweenCursor(false)
  table.insert(gui._onKeyPressed, self)
end

function TextInput:draw()
  local ax = self.absX
  local ay = self.absY
  self:drawBorder(self.style.border)
  love.graphics.rectangle("fill", ax, ay, self.width, self.height)
  --love.graphics.setScissor(ax, ay - 1, self.width, self.height + 1)
  
  -- text
  love.graphics.pushColor(self.style.text)
  love.graphics.print(self.text, ax + self.padding, ay + self.padding)
  love.graphics.popColor()
  
  -- selection
  if self._selection ~= 0 then
    local pos1 = math.min(self._cursor - 1, self._cursor - 1 + self._selection)
    local pos2 = math.max(self._cursor - 1, self._cursor - 1 + self._selection)
    local startX = ax + self.padding + self.style.fontSmall:getWidth(self.text:sub(1, pos1 - 1))
    love.graphics.pushColor(self.style.selection)
    love.graphics.rectangle("fill", startX, ay + self.padding, startX + self.style.fontSmall:getWidth(self.text:sub(pos1, pos2)), self._fontHeight)
    love.graphics.popColor()
  end
  
  -- cursor
  local width = self.style.fontSmall:getWidth(self.text:sub(1, self._cursor - 1))
  love.graphics.pushColor(self.cursorColor)
  love.graphics.rectangle("fill", ax + math.min(width, self.width - self.padding * 2) + self.padding, ay + self.padding, 2, self._fontHeight)
  love.graphics.popColor()
  
  --love.graphics.setScissor()
end

function TextInput:deleteSelection()
  if self._selection ~= 0 then
    local str = ""
    local pos1 = math.min(self._cursor - 1, self._cursor - 1 + self._selection)
    local pos2 = math.max(self._cursor - 1, self._cursor - 1 + self._selection)
    
    if pos1 ~= 1 then str = str .. self.text:sub(1, pos1 - 1) end
    if pos2 ~= #self.text then str = str .. self.text:sub(pos2 + 1) end
    self.text = str
    self._cursor = self._cursor - 1
  elseif self._cursor > 1 then
    local str = ""
    if self._cursor > 2 then str = str .. self.text:sub(1, self._cursor - 2) end
    if self._cursor <= #self.text + 1 then str = str .. self.text:sub(self._cursor) end
    self.text = str
    self._cursor = self._cursor - 1
  end
end

function TextInput:keyPressed(k, unicode)
  if self.activated then
    if k == 'left' then
      if (key.down.lshift or key.down.rshift) and self._cursor + self._selection > 1 then
        self._selection = self._selection - 1
      elseif self._cursor > 1 then
        self._cursor = self._cursor - 1
      end
      
      self.cursorColor[4] = 255
    elseif k == 'right' then
      if (key.down.lshift or key.down.rshift) and self._cursor + self._selection < #self.text then
        self._selection = self._selection + 1
      elseif self._cursor <= #self.text then
        self._cursor = self._cursor + 1
      end

      self.cursorColor[4] = 255
    elseif self.editable then
      if k == 'backspace' then
        self:deleteSelection()
      elseif k == 'delete' then
        if self._selection ~= 0 then
          self:deleteSelection()
        elseif self._cursor > 0 then
          -- not sure whether this works, we'll have to see
          local str = ""
          if self._cursor > 1 then str = str .. self.text:sub(1, self._cursor - 1) end
          if self._cursor <= #self.text then str = str .. self.text:sub(self._cursor + 1) end
          self.text = str
        end
      elseif unicode ~= 0 and unicode < 1000 then
        self.text = self.text:insert(self._cursor, string.char(unicode))
        self._cursor = self._cursor + 1
      end
    end
    
    print('cursor', self._cursor)
    print('selection', self._selection)
    print('text', self.text)
    print()
    
  end
end

function TextInput:_tweenCursor(on)
  delay(self.blinkDelay, function()
    self.cursorColor[4] = (on and 255 or 0)
    self:_tweenCursor(not on)
  end)
end
