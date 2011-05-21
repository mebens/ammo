-- SETUP RANDOM NUMBERS --

math.randomseed(os.time())
math.random()
math.random()
math.random()

-- IMPORTS --

local path = ({...})[1]:gsub("%.init", "")
local imports = {
  {
    'lib',
    
    'middleclass',
    'strong',
  },
  
  {
    'ds',
    
    'SpecialLinkedList',
    'Vector'
  },
  
  {
    'core',
    
    -- modules/functions
    'global',
    'extensions',
    'input',
    'ease',
    
    -- classes
    'Camera',
    'World',
    'Entity',
    'Sfx',
    'Tween',
    'AttrTween',
  }
}

-- auto-load love.physics oriented classes
if love.physics then
  table.insert(imports, {
    'extras',
    'PhysicalEntity',
    'PhysicalWorld'
  })
end

for _, v in ipairs(imports) do
  for i = 2, #v do
    require(path .. '.' .. v[1] .. '.' .. v[i])
  end
end

-- inspect.lua requries us to catch the return value
table.inspect = require(path .. '.lib.inspect.inspect')

-- RESOURCES.INIT AUTOLOAD --

if love.filesystem.exists('resources/init.lua') then
  require('resources.init')
end
