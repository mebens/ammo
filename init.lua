ammo = {}
ammo.path = ({...})[1]:gsub("%.init", "")

require(ammo.path .. ".lib.middleclass")
require(ammo.path .. ".core.init")
