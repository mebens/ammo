Control = class('Control', Entity):include(MouseInteractive)

function Control:initialize(x, y)
  Entity.initialize(self)
  self.x = x or 0
  self.y = y or 0
  self.style = gui.style
  self.draggable = false
  self.showBorder = true
end

function Control:update()
  if self._mouseDown then
    self.x = self._mouseDown.ox + (mouse.x - self._mouseDown.x)
    self.y = self._mouseDown.oy + (mouse.y - self._mouseDown.y)
  end

  self:updateMouse()
  
  if self.activated and mouse.pressed.l and self._mouseState ~= 'down' then
    gui.active = nil
  end
end

function Control:mouseDown(x, y)
  if self.draggable then
    -- ox = original self.x
    -- oy = original self.y
    self._mouseDown = { ox = self.x, oy = self.y, x = x, y = y }
  end
  
  if not self.activated then gui.active = self end
end

function Control:mouseUp()
  self._mouseDown = nil
end

function Control:drawBorder(color)
  if self.showBorder then
    love.graphics.pushColor(color)
    love.graphics.rectangle("line", self.absX - 1, self.absY - 1, self.width + 2, self.height + 2)
    love.graphics.popColor()
  end
end
