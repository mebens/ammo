ammo = {}
ammo.path = ({...}):gsub("%.init$", "")

-- only include middleclass if it's not already there or if it's not v3.x
if not (class and class.Object) then
  class = require(ammo.path .. ".lib.middleclass")
end

require(ammo.path .. ".ammo") -- ammo requires the essentials
require(ammo.path .. ".Entity") -- these two are recommended, but not absolutely crucial
require(ammo.path .. ".Sound")
