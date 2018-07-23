local Info = class("Info")

local function formatNumber(num)
  if math.round(num) == num then
    return tostring(num)
  else
    return ("%.1f"):format(num)
  end
end

function Info:initialize(debug, title, func, graph, interval, numFunc)
  self.title = title
  self.source = func
  self.graphSource = numFunc or func
  self.graph = graph
  self.interval = interval or 1
  self.height = 50
  self.spacing = 5
  self.padding = 3
  
  self.dsettings = debug.settings
  self.data = {}
  self.timer = self.interval
  self.alwaysRecord = self.graph
end

function Info:update(dt)
  if not (self.graph or self.alwaysRecord) then return end
  
  if self.timer <= 0 then
    local n = self.graphSource()
    self.timer = self.timer + self.interval
    
    if type(n) == "number" then
      self.data[#self.data + 1] = n
      self.data.min = self.data.min and math.min(self.data.min, n) or n
      self.data.max = self.data.max and math.max(self.data.max, n) or n
      
      local maxEntries = math.floor((self.dsettings.infoWidth - self.dsettings.padding * 2) / self.spacing)
      while #self.data > maxEntries do table.remove(self.data, 1) end
    end
  else
    self.timer = self.timer - dt
  end
end

function Info:draw(x, y)
  local s = self.dsettings
  local width = s.infoWidth - s.padding * 2
  local yOffset = s.font:getHeight() + self.padding

  -- info text
  love.graphics.setColor(s.color)
  love.graphics.setFont(s.font)
  love.graphics.printf(self.title .. s.infoSeparator .. tostring(self.source() or ""), x, y, width)
  
  if self.dsettings.drawGraphs and self.graph then
    local x1, y1
    local x2, y2
    
    local lineStyle = love.graphics.getLineStyle()
    love.graphics.setLineWidth(1)
    love.graphics.setLineStyle(s.graphLineStyle)
    love.graphics.setColor(s.graphColor)
    
    -- graph lines
    for i = 1, #self.data do
      local n = self.data[i]
      x2 = x + self.spacing * (i - 1)
      y2 = y + yOffset + self.height - self.height * math.scale(n, self.data.min, self.data.max, 0, 1)
      if not x1 then x1, y1 = x2, y2 end
      love.graphics.line(x1, y1, x2, y2)
      x1, y1 = x2, y2
    end
    
    -- min/max text
    love.graphics.setFont(s.graphFont)
    love.graphics.setColor(s.graphTextColor)
    love.graphics.printf(formatNumber(self.data.max), x, y + yOffset, width, "right")
    love.graphics.printf(formatNumber(self.data.min), x, y + yOffset + self.height - s.graphFont:getHeight(), width, "right")
    
    yOffset = yOffset + self.height
    love.graphics.setLineStyle(lineStyle)
  end
  
  return yOffset
end

return Info
