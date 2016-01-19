local path = ({...})[1]:gsub("%.init", "")
require(path .. ".Tween")
require(path .. ".AttrTween")
ease = require(path .. ".ease")
require(path .. ".tweens")
ammo.ext.tweens = true
