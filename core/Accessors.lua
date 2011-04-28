-- PROBLEMS
-- It doesn't work with Indexable

local mt = {}

function mt:__index(key)
  print(self)
  local result = self.class.__classDict[key] or rawget(self, '_' .. key)
  
  if result then
    return result
  else
    local getter = rawget(self, '_get' .. key:gsub('^%l', string.upper))
    
    if type(getter) == 'function' then
      return getter(self)
    elseif type(rawget(self, getter)) == 'table' then
      return self[getter][key]
    end
  end
end
  
function mt:__newindex(key, value)
  local setter = rawget(self, '_set' .. key:gsub('^%l', string.upper))

  if not setter then
    rawset(self, key, value)
    return
  end

  if type(setter) == 'function' then
    setter(self, value)
  else
    if setter == '_' then
      self['_' .. key] = value
    elseif type(rawget(self, setter)) == 'table' then
      self[setter][key] = value
    end
  end
end

--[[local function _modifyClass(cls)
  local oldAlloc = cls.allocate
  local oldSubclass = cls.subclass
  rawset(cls, '__getters', setmetatable({}, { __index = cls.superclass.__getters }))
  rawset(cls, '__setters', setmetatable({}, { __index = cls.superclass.__setters }))
  
  function cls:allocate(...)
    local instance = oldAlloc(self, ...)
    local instanceMt = getmetatable(instance)
    
    instanceMt.__index = mt.__index
    if setters then instanceMt.__newindex = mt.__newindex end
    --print(self, instance)
    return instance
  end
  
  function cls:subclass(...)
    return _modifyClass(oldSubclass(self, ...))
  end
  
  return cls
end

Accessors = {}

function Accessors:included(cls, setters) _modifyClass(cls) end
function Accessors:getter(name, obj) self.__getters[name] = obj end
function Accessors:setter(name, obj) self.__setters[name] = obj end

function Accessors:getterSetter(name, getter, setter)
  self.__getters[name] = getter
  self.__setters[name] = setter or getter
end]]

local function _modifyClass(cls)
  local oldAlloc = cls.allocate
  local oldSubclass = cls.subclass

  if cls.allocate ~= cls.superclass.allocate or not includes(Accessors, cls.superclass) then
    function cls.allocate(cls, ...)
      local instance = oldAlloc(cls, ...)
      local instanceMt = getmetatable(instance)
      instanceMt.__index = mt.__index
      instanceMt.__newindex = mt.__newindex
      return instance
    end
  end
  
  if cls.subclass ~= cls.superclass.subclass or not includes(Accessors, cls.superclass) then
    function cls.subclass(cls, ...) return _modifyClass(oldSubclass(cls, ...)) end
  end
  
  return cls -- to enable the one-liner above
end

Accessors = {}

function Accessors:included(cls) _modifyClass(cls) end
function Accessors:getter(name, obj) self.__getters[name] = obj end
function Accessors:setter(name, obj) self.__setters[name] = obj end
