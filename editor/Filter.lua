Filter = class('Filter')

function Filter:initialize()
  -- settings
  self.visible = true
  self.printText = true
  self.showPoint = true
  
  -- colors
  self.boundingColor = { 255, 254, 222 }
  self.pointColor = { 235, 92, 84 }
  self.textColor = { 255, 255, 255 }
end

function Filter:drawFilter(e)
  if self.visible and not e._editor then
    -- we need to only show this if the entity is selected
    love.graphics.pushColor(self.boundingColor)
    love.graphics.rectangle("line", e.x, e.y, e.width, e.height)
    love.graphics.popColor()
    
    if self.showPoint then
      love.graphics.pushColor(self.pointColor)
      love.graphics.point(e.x, e.y)
      love.graphics.popColor()
    end
    
    if self.printText then
      love.graphics.pushColor(self.textColor)
      love.graphics.print(e.name and e.name .. " (" .. e.class.name .. ")" or e.class.name, e.x, e.y - 15)
      love.graphics.popColor()
    end
  end
end
