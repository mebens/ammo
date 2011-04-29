FollowingCamera = class('FollowingCamera', Camera)

function FollowingCamera:initialize(target, zoom, rotation)
  Camera.initialize(self, 0, 0, zoom, rotation)
  self.target = target
	self.move = true
	
	if target then
		self.x = target.x - love.graphics.width / 2
		self.y = target.y - love.graphics.height / 2
	end
end

function FollowingCamera:update(dt)
	if self.target and self.move then
    self.x = self.x - (self.x - (self.target.x - love.graphics.width / 2)) * dt * self.speed
    self.y = self.y - (self.y - (self.target.y - love.graphics.height / 2)) * dt * self.speed
  end
end
