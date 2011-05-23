require('x.init')
require('x.gui.init')
require('utils')
require('editor')
require('Editable')

function love.load(args)
  if args[2] then editor.config.path = args[2] end
  setIdentity(editor.config.path)
  
  -- requires
  if editor.config.resources then require(editor.config.resources) end
  if editor.include then loadClasses(editor.include) end
  if editor.entities then loadClasses(editor.entities, 'entities') end
  if editor.worlds then loadClasses(editor.worlds, 'worlds') end
end

love.keypressed = gui.keyPressed
