-- AMMO AND AMMO.PATH --

ammo = {}
ammo.path = ({...})[1]:gsub("%.init", "")

-- IMPORTS --

require(ammo.path .. ".lib.middleclass")
require(ammo.path .. ".lib.strong")
require(ammo.path .. ".core.init")
table.inspect = require(ammo.path .. ".lib.inspect.inspect")

-- ADD-ON LIBRARIES

local filepath = ammo.path:gsub("%.", "/")

if love.physics and love.filesystem.exists(filepath .. "/physics") then
  require(ammo.path .. ".physics.init")
end

if love.filesystem.exists(filepath .. "/tweens") then
  require(ammo.path .. ".tweens.init")
end

-- SETUP RANDOM NUMBERS --

math.randomseed(os.time())
math.random()
math.random()
math.random()

-- RESOURCES.INIT AUTOLOAD --

if love.filesystem.exists("resources/init.lua") then require("resources.init") end
