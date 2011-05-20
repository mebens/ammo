Button = class('Button', Control)
Button._mt = {}

function Button._mt:__newindex(key, value)
  if key == 'text' then
    self._text = value
    self.width = width or self.style.fontSmall:getWidth(value) + self.padding * 2
    self.height = height or self.style.fontSmall:getHeight() + self.padding * 2
  elseif key == 'image' then
    self._image = value
    self.width = width or value:getWidth() + self.padding * 2
    self.height = height or value:getHeight() + self.padding * 2
  else
    Entity._mt.__newindex(self, key, value)
  end
end

Button:enableAccessors()

function Button:initialize(display, x, y, width, height)
  Control.initialize(self, x, y)
  self.color = table.copy(self.style.medBg)
  self.padding = 5
  self.showBorder = true
  self:applyAccessors()
  self[type(display) == 'string' and 'text' or 'image'] = display
end

function Button:draw()
  local ax = self.absX
  local ay = self.absY
  self:drawBorder(self.style.border)
  love.graphics.rectangle("fill", ax, ay, self.width, self.height)
  
  if self.text then
    love.graphics.pushColor(self.style.text)
    love.graphics.print(self._text, ax + self.padding, ay + self.padding)
  else
    love.graphics.pushColor(255, 255, 255)
    love.graphics.draw(self._image, ax + self.padding, ay + self.padding)
  end
  
  love.graphics.popColor()
end

function Button:mouseOver()
  if self.onOver then self:onOver() end
  if self.colorTween then self.colorTween:stop() end
  self.colorTween = tween(self.color, .15, self.style.medActiveBg)
end

function Button:mouseOut()
  if self.onOut then self:onOut() end
  if self.colorTween then self.colorTween:stop() end
  self.colorTween = tween(self.color, .15, self.style.medBg)
end

function Button:mouseUp(x, y)
  Control.mouseUp(self)
  if mouse.released.l and self.onClick then self:onClick() end
end
