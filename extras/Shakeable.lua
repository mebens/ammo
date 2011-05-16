Shakeable = {}

function Shakeable:shake(amount)
  self._shakeFactor = amount
  
  tween(self, .1, { _shakeFactor = -amount, onComplete = function()
    tween(self, .1, { _shakeFactor = amount / 2, onComplete = function()
      tween(self, .1, { _shakeFactor = (-amount) / 2, onComplete = function()
        tween(self, .1, { _shakeFactor = amount / 8, onComplete = function()
          tween(self, .1, { _shakeFactor = (-amount) / 8, onComplete = function()
            -- we must do this because this is called before AttrTween.update
            -- therefore setting it to nil will be un-done otherwise
            delayFrames(1, function() self._shakeFactor = nil end)
          end })
        end })
      end })
    end })
  end })
end

function Shakeable:_getCoordValue(axis, value)
  return Camera._getCoordValue(self, axis, self._shakeFactor and value + self._shakeFactor or value)
end
