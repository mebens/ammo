MouseInteractive = {}

function MouseInteractive:updateMouse()
  local ax = self.absX
  local ay = self.absY
  local mx = mouse.x
  local my = mouse.y
  
  if mx >= ax and mx <= ax + self.width and my >= ay and my <= ay + self.height then
    if self._mouseState == 'out' then
      self._mouseState = 'over'
      if self.mouseOver then self:mouseOver(mx, my) end
    end
    
    if self._mouseState ~= 'down' and mouse.pressed.any then
      self._mouseState = 'down'
      if self.mouseDown then self:mouseDown(mx, my) end
    elseif self._mouseState == 'down' and mouse.released.any then
      self._mouseState = 'over'
      if self.mouseUp then self:mouseUp(mx, my) end
    end
  elseif self._mouseState ~= 'out' then
    if self._mouseState ~= nil and self.mouseOut then self:mouseOut(mx, my) end
    self._mouseState = 'out'
  end
end
