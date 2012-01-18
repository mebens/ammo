SpecialLinkedList = class("SpecialLinkedList")

local mt = {}

function mt:__index(key)
  return rawget(self, "_" .. key) or SpecialLinkedList.__classDict[key]
end

function SpecialLinkedList:initialize(nextProp, prevProp, ...)
  -- attributes
  self._first = nil
  self._last = nil
  self._np = nextProp or "_next"
  self._pp = prevProp or "_prev"
  self._length = 0
  
  -- enabled getter functionality
  local old = getmetatable(self)
  old.__index = mt.__index
  
  -- push elements, if any
  self:push(...)
end

function SpecialLinkedList:push(...)
  for _, v in ipairs{...} do
    if not self._first then
      self._first = v
      self._last = v
    else
      self._last[self._np] = v
      v[self._pp] = self._last
      self._last = v
    end
  end
  
  self._length = self._length + select("#", ...)
end

function SpecialLinkedList:unshift(...)
  for _, v in ipairs{...} do
    if not self._first then
      self._first = v
      self._last = v
    else
      self._first[self._pp] = v
      v[self._np] = self._first
      self._first = v
    end
  end
  
  self._length = self._length + select("#", ...)
end

function SpecialLinkedList:insert(node, after)
  if after[self._np] then
    after[self._np][self._pp] = node
  else
    self._last = node
  end

  after[self._np] = node
  self._length = self._length + 1
  return node
end

function SpecialLinkedList:pop()
  if self._last then
    ret = self._last
    ret[self._pp][self._np] = nil
    self._last = ret[self._pp]
    ret[self._pp] = nil
    self._length = self._length - 1
    return ret
  end
end

function SpecialLinkedList:shift()
  if self._first then
    ret = self._first
    ret[self._np][self._pp] = nil
    self._first = ret[self._np]
    ret[self._np] = nil
    self._length = self._length - 1
    return ret
  end
end

function SpecialLinkedList:remove(...)
  for _, v in ipairs{...} do
    if v[self._np] then
      if v[self._pp] then
        v[self._np][self._pp] = v[self._pp]
        v[self._pp][self._np] = v[self._np]
      else
        v[self._np][self._pp] = nil
        self._first = v[self._np]
      end
    elseif v[self._pp] then
      v[self._pp][self._np] = nil
      self._last = v[self._pp]
    else
      self._first = nil
      self._last = nil
    end

    v[self._np] = nil
    v[self._pp] = nil
    self._length = self._length - 1
  end
end

function SpecialLinkedList:clear(complete)
  complete = complete or false
  self._first = nil
  self._last = nil
  self._length = 0
  
  if complete then
    for v in self:getIterator() do
      v[self._np] = nil
      v[self._pp] = nil
    end
  end
end

function SpecialLinkedList:bringForward(node)
  if node[self._np] then
    if node[self._pp] then
      node[self._np][self._pp] = node[self._pp]
      node[self._pp] = node[self._np]
    else
      self._first = node[self._np]
    end
    
    if node[self._np][self._np] then
      node[self._np] = node[self._np][self._np]
    else
      self._last = node
    end
    
    node[self._np][self._np] = node
    return true
  else
    return false
  end
end

function SpecialLinkedList:sendBackward(node)
  if node[self._pp] then
    if node[self._np] then
      node[self._pp][self._np] = node[self._np]
      node[self._np] = node[self._pp]
    else
      self._last = node[self._pp]
    end
    
    if node[self._pp][self._pp] then
      node[self._pp] = node[self._pp][self._pp]
    else
      self._first = node
    end
    
    node[self._pp][self._pp] = node
    return true
  else
    return false
  end
end

function SpecialLinkedList:bringToFront(node)
  if node[self._pp] then
    if node[self._np] then
      node[self._np][self._pp] = node[self._pp]
      node[self._pp][self._np] = node[self._np]
    else
      self._last = node[self._pp]
    end
    
    self._first[self._pp] = node
    self._first = node
    return true
  else
    return false
  end
end

function SpecialLinkedList:sendToBack(node)
  if node[self._np] then
    if node[self._pp] then
      node[self._pp][self._np] = node[self._np]
      node[self._np][self._pp] = node[self._pp]
    else
      self._first = node[self._np]
    end
    
    self._last[self._np] = node
    self._last = node
    return true
  else
    return false
  end
end

function SpecialLinkedList:getAll()
  local ret = {}
  local v = self._first
  
  while v do
    table.insert(ret, v)
    v = v[self._np]
  end
  
  return ret
end

local function iterate(self, current)
  if not current then
    current = self._first
  elseif current then
    current = current[self._np]
  end
  
  return current
end

local function reverseIterate(self, current)
  if not current then
    current = self._last
  elseif current then
    current = current[self._pp]
  end
  
  return current
end

function SpecialLinkedList:getIterator(reverse)
  return (reverse and reverseIterate or iterate), self, nil
end
