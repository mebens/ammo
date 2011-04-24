-- PROBLEMS
-- It doesn't work with Indexable

Accessors = {}

function Accessors:included(cls, setters)
  local oldAlloc = cls.allocate
  local mt = {}
  cls.__getters = {}
  
  function mt:__index(key)
    local result = rawget(self, '_' .. key) or cls.__classDict[key]
    
    if result then
      return result
    else
      local getter = cls.__getters[key]
      
      if type(getter) == 'function' then
        return getter()
      else
        return getter[key]
      end
    end
  end
  
  if setters then
    cls.__setters = {}
    
    function mt:__newindex(key, value)
      local setter = cls.__setters[key]
      
      if not setter then
        rawset(self, key, value)
        return
      end
      
      if type(setter) == 'function' then
        setter(value)
      elseif type(setter) == 'string' then
        rawset(self, setter, value)
      else
        setter[key] = value
      end
    end
  end
  
  function cls:allocate(...)
    local instance = oldAlloc(...)
    local instanceMt = getmetatable(instance)
    
    instanceMt.__index = mt.__index
    if setters then instanceMt.__newindex = mt.__newindex end
    return instance
  end
end

function Accessors:getter(name, obj) self.__getters[name] = obj end
function Accessors:setter(name, obj) self.__setters[name] = obj end

function Accessors:getterSetter(name, getter, setter)
  self.__getters[name] = getter
  self.__setters[name] = setter
end
