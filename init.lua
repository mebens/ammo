-- X AND X.PATH --

x = {}
x.path = ({...})[1]:gsub("%.init", "")

-- IMPORTS --

require(x.path .. ".lib.middleclass")
require(x.path .. ".lib.strong")
require(x.path .. ".core.x")
require(x.path .. ".core.extensions")
require(x.path .. ".core.input")
require(x.path .. ".core.camera")
require(x.path .. ".core.SpecialLinkedList")
require(x.path .. ".core.Vector")
require(x.path .. ".core.World")
require(x.path .. ".core.Entity")
require(x.path .. ".core.Sound")

-- inspect.lua
table.inspect = require(x.path .. ".lib.inspect.inspect")

-- ADD-ON LIBRARIES

local filepath = x.path:gsub("%.", "/")

if love.physics and love.filesystem.exists(filepath .. "/physics") then
  require(x.path .. ".physics.init")
end

if love.filesystem.exists(filepath .. "/tweens") then
  require(x.path .. ".tweens.init")
end

-- SETUP RANDOM NUMBERS --

math.randomseed(os.time())
math.random()
math.random()
math.random()

-- RESOURCES.INIT AUTOLOAD --

if love.filesystem.exists("resources/init.lua") then require("resources.init") end
