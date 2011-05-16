AttrTween = class('AttrTween', Tween)

function AttrTween:initialize(obj, duration, values, tweenType, complete, ease)
  Tween.initialize(self, duration, tweenType, complete, ease)
  self._obj = obj
  self._start = {}
  self._range = {}
  
  for k, v in pairs(values) do
    local val = obj[k]
    
    if val then
      self._start[k] = val
      self._range[k] = v - val
    end
  end
end

function AttrTween:update(dt)
  Tween.update(self, dt)
  
  for k, v in pairs(self._start) do
    self._obj[k] = v + self._range[k] * self._t
  end  
end
