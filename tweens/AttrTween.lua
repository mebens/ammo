AttrTween = class('AttrTween', Tween)

function AttrTween:initialize(obj, duration, values, ease, complete, ...)
  Tween.initialize(self, duration, ease, complete, ...)
  self._obj = obj
  self._init = {}
  self._range = {}
  
  for k, v in pairs(values) do
    local val = obj[k]
    
    if val then
      self._init[k] = val
      self._range[k] = v - val
    end
  end
end

function AttrTween:update(dt)
  Tween.update(self, dt)
  
  for k, v in pairs(self._init) do
    self._obj[k] = v + self._range[k] * self._t
  end  
end
