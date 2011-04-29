Follow = {}

function Follow:included(cls)
	local oldUpdate = cls.update
	local oldInit = cls.initialize
	
	function cls:initialize(target, zoom, rotation)
		oldInit(self, 0, 0, zoom, rotation)
		self.target = target
		
		if target then
			self.x = target.x - love.graphics.width / 2
			self.y = target.y - love.graphics.height / 2
		end
	end
	
	function cls:update(dt)
		oldUpdate(self, dt)
		
		-- ~= false ensures that the user doesn't have to set this to true
		if self.target and self.move ~= false then
	    self.x = self.x - (self.x - (self.target.x - love.graphics.width / 2)) * dt * self.speed
	    self.y = self.y - (self.y - (self.target.y - love.graphics.height / 2)) * dt * self.speed
	  end
	end
end
