local path = ({...})[1]:gsub("%.init", "")
require(path .. ".Sound")
require(path .. ".SoundPool")
ammo.ext.audio = true
