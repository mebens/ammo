require('x')
require('x.gui')
require('utils')
require('Editor')

function love.load(args)
  if args[2] then Editor.config.path = args[2] end
  setIdentity(Editor.config.path)
  
  -- requires
  if Editor.config.resources then require(Editor.config.resources) end
  if Editor.include then loadClasses(Editor.include) end
  if Editor.entities then loadClasses(Editor.entities, 'entities') end
  if Editor.worlds then loadClasses(Editor.worlds, 'worlds') end
end

