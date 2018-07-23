ammo = {}
ammo.path = ({...})[1]:gsub("%.init$", "")

-- only include middleclass if it's not already defined
if not class then
  class = require(ammo.path .. ".lib.middleclass")
end

require(ammo.path .. ".core")
require(ammo.path .. ".extensions")
