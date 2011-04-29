PositionalVolume = {}

function PositionalVolume:included(cls, min, max, target)
	function cls:play(x, y, volume, pan)
		if not volume then
		  local dist = Vector.dist(Vector(target.x + love.graphics.width, target.y + love.graphics.height, Vector(x, y))
		  volume = math.clamp(1 / (dist / 100), min, max)
		end
		
		Sfx.play(self, x, y, volume, pan)
	end
end
