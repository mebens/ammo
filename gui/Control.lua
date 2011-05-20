Control = class('Control', Entity):include(MouseInteractive)

function Control:initialize(x, y)
  Entity.initialize(self)
  self.x = x or 0
  self.y = y or 0
  self.style = gui.style
  self.draggable = false
end

function Control:update()
  if self._mouseDown then
    self.x = self._mouseDown.ox + (mouse.x - self._mouseDown.x)
    self.y = self._mouseDown.oy + (mouse.y - self._mouseDown.y)
  end
  
  self:updateMouse()
end

function Control:mouseDown(x, y)
  if self.draggable then
    -- ox = original self.x
    -- oy = original self.y
    self._mouseDown = { ox = self.x, oy = self.y, x = x, y = y }
  end
end

function Control:mouseUp()
  self._mouseDown = nil
end
