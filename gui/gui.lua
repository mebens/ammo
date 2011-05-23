gui = setmetatable({}, {
  __index = function(self, key)
    local result = rawget(self, '_' .. key)
    if result then return result end
  end,
  
  __newindex = function(self, key, value)
    if key == 'active' then
      if self._active then
        self._active.activated = false
        if self._active.onDeactivate then self._active:onDeactivate() end
      end
      
      self._active = value
      
      if value then
        value.activated = true
        if value.onActivate then value:onActivate() end
      end
    else
      rawset(self, key, value)
    end
  end
})

gui.style = {
  darkBg = { 35, 35, 35 },
  darkActiveBg = { 55, 55, 55 },
  medBg = { 60, 60, 60 },
  medActiveBg = { 80, 80, 80 },
  lightBg = { 170, 170, 170 },
  lightActiveBg = { 200, 200, 200 },
  
  border = { 145, 145, 145 },
  activeBorder = { 23, 181, 230 },
  
  text = { 240, 240, 240 },
  darkText = { 20, 20, 20 },
  selection = { 107, 213, 255, 30 },
  fontSmall = love.graphics.newFont(12),
  fontMed = love.graphics.newFont(16),
  fontLarge = love.graphics.newFont(24)
}

gui._onKeyPressed = {}

function gui.keyPressed(key, unicode)
  for _, v in pairs(self._onKeyPressed) do
    v:keyPressed(key, unicode)
  end
end
