local path = ({...})[1]:gsub("%.init", "")
require(path .. ".Tween")
require(path .. ".Delay")
ease = require(path .. ".ease")
ammo.ext.tweens = true
