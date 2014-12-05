ammo = {}
ammo.path = ({...})[1]:gsub("%.init", "")

-- only include MiddleClass if it hasn't already been included
if not Object then require(ammo.path .. ".lib.middleclass.middleclass") end
require(ammo.path .. ".core.init")
