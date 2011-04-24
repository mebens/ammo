local path = ({...})[1]:gsub("%.init", "")
local imports = {
  {
    'lib',
    'middleclass'
  },
  
  {
    'ds',
    'SpecialLinkedList',
    'Vector'
  },
  
  {
    'core',
    'extensions',
    'camera',
    'World',
    'PhysicalWorld',
    'Entity',
    'PhysicalEntity',
    'Sfx',
    'Tween',
    'AttrTween',
    'ease'
  }
}

for _, v in ipairs(imports) do
  for i = 2, #v do
    require(path .. '.' .. v[1] .. '.' .. v[i])
  end
end
