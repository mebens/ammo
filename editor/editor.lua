editor = {}
editor.config = require('config')
editor.entities = {}
editor.worlds = {}

function editor.load(cls)
  local world = cls:new()
  world:include(Editable)
  x.world = world
end
