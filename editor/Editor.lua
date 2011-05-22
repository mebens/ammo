Editor = class('Editor', World)
Editor.config = require('config')
Editor.entities = {}
Editor.worlds = {}

function Editor:initialize()
  World.initialize(self)
end

function Editor:update()
end
