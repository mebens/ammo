Follow = {}

function Follow:included(cls, target, speed)
  local oldUpdate = cls.update
  
  if subclassOf(Object, cls) then
    local oldInit = cls.initialize
    
    function cls:initialize(target, zoom, rotation)
      oldInit(self, 0, 0, zoom, rotation)

      self.target = target
    	self.move = true
    	self.speed = 7

    	if target then
    		self.x = target.x - love.graphics.width / 2
    		self.y = target.y - love.graphics.height / 2
    	end
    end
  else
    cls.target = target
  	cls.move = true
  	cls.speed = speed or 7

  	if target then
  		cls.x = target.x - love.graphics.width / 2
  		cls.y = target.y - love.graphics.height / 2
  	end
	end

  function cls:update(dt)
    oldUpdate(dt)
    
  	if self.target and self.move then
      self.x = self.x - (self.x - (self.target.x - love.graphics.width / 2)) * dt * self.speed
      self.y = self.y - (self.y - (self.target.y - love.graphics.height / 2)) * dt * self.speed
    end
  end
end

