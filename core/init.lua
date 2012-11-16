-- ammo is most likely defined the main init.lua
if not ammo then
  ammo = {}
  ammo.path = ({...})[1]:gsub("%.core%.init", "")
end

require(ammo.path .. ".core.extensions")
require(ammo.path .. ".core.LinkedList")
require(ammo.path .. ".core.Vector")
require(ammo.path .. ".core.Camera")
require(ammo.path .. ".core.World")
require(ammo.path .. ".core.Entity")
require(ammo.path .. ".core.Sound")

ammo.version = "0.2.3"
ammo.ext = {}
ammo._world = World:new()

setmetatable(ammo, {
  __index = function(self, key) return rawget(self, "_" .. key) end,
  
  __newindex = function(self, key, value)
    if key == "world" then
      self._goto = value
    else
      rawset(self, key, value)
    end
  end
})

function ammo.update(dt)
  _G.dt = dt
  
  -- update
  if ammo._world and ammo._world.active then
    ammo._world:update(dt)
  end
  
  -- world switch
  if ammo._goto then
    if ammo._world then ammo._world:stop() end
    ammo._world = ammo._goto
    ammo._goto = nil
    
    if ammo._world then
      ammo._world:_updateLists() -- make sure all entities are added (or removed) beforehand
      ammo._world:start()
    end
  end
end

function ammo.draw()
  if ammo._world and ammo._world.visible then
    ammo._world:draw()
  end
end

if not love.update then love.update = ammo.update end
if not love.draw then love.draw = ammo.draw end
