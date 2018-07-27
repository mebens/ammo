if not ammo then
  ammo = {}
  ammo.path = ({...})[1]:gsub("%.all$", "")

  -- only include middleclass if it's not already defined
  if not class then
    class = require(ammo.path .. ".lib.middleclass")
  end

  require(ammo.path .. ".core")
end

require(ammo.path .. ".extensions")
require(ammo.path .. ".modules")
require(ammo.path .. ".callbacks")
