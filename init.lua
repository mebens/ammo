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
    'strong'
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
    'PhysicalWorld',
    'Entity',
    'PhysicalEntity',
    'Sfx',
    'Tween',
    'AttrTween',
  }
}

for _, v in ipairs(imports) do
  for i = 2, #v do
    require(path .. '.' .. v[1] .. '.' .. v[i])
  end
end

-- RESOURCES.INIT AUTOLOAD --

if love.filesystem.exists('resources/init.lua') then
	require('resources.init')
end
