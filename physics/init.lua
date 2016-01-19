local path = ({...})[1]:gsub("%.init", "")
require(path .. ".PhysicalEntity")
require(path .. ".PhysicalWorld")
ammo.ext.physics = true
