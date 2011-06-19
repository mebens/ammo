-- X AND X.PATH --

x = {}
x.path = ({...})[1]:gsub("%.init", "")

-- IMPORTS --

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
    'Sound',
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
    require(x.path .. '.' .. v[1] .. '.' .. v[i])
  end
end

-- inspect.lua requries us to catch the return value
table.inspect = require(x.path .. '.lib.inspect.inspect')

-- SETUP RANDOM NUMBERS --

math.randomseed(os.time())
math.random()
math.random()
math.random()

-- RESOURCES.INIT AUTOLOAD --

if love.filesystem.exists('resources/init.lua') then
  require('resources.init')
end
