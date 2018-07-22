LinkedList = class("LinkedList")

function LinkedList:__index(key)
  local result = rawget(self, "_" .. key) or LinkedList.__instanceDict[key]
  
  if result then
    return result
  elseif key == "all" then
    local ret = {}
    local v = self._first
    
    while v do
      table.insert(ret, v)
      v = v[self._np]
    end
    
    return ret
  end
end

function LinkedList:__len()
  return self._length
end

function LinkedList:initialize(nextProp, prevProp, ...)
  self._first = nil
  self._last = nil
  self._np = nextProp or "_next"
  self._pp = prevProp or "_prev"
  self._inp = self._np .. "iter"
  self._ipp = self._pp .. "iter"
  self._length = 0
  for _, v in ipairs{...} do self:push(v) end
end

function LinkedList:push(node)
  if self._first then
    self._last[self._np] = node
    node[self._pp] = self._last
    self._last = node
  else
    self._first = node
    self._last = node
  end
  
  self._length = self._length + 1
end

function LinkedList:unshift(node)
  if self._first then
    self._first[self._pp] = node
    node[self._np] = self._first
    self._first = node
  else
    self._first = node
    self._last = node
  end
  
  self._length = self._length + 1
end

function LinkedList:insert(node, after)
  if after then
    if after[self._np] then
      after[self._np][self._pp] = node
      node[self._np] = after[self._np]
    else
      self._last = node
    end
    
    node[self._pp] = after    
    after[self._np] = node
    self.length = self.length + 1
  elseif not self._first then
    self._first = node
    self._last = node
  end
end

function LinkedList:pop()
  if self._last then
    local ret = self._last
    
    if ret[self._pp] then
      ret[self._pp][self._np] = nil
      self._last = ret[self._pp]
      ret[self._pp] = nil
    else
      -- this was the only element
      self._first = nil
      self._last = nil
    end
    
    self._length = self._length - 1
    return ret
  end
end

function LinkedList:shift()
  if self._first then
    local ret = self._first
    
    if ret[self._np] then
      ret[self._np][self._pp] = nil
      self._first = ret[self._np]
      ret[self._np] = nil
    else
      -- this was the only element
      self._first = nil
      self._last = nil
    end
    
    self._length = self._length - 1
    return ret
  end
end

function LinkedList:remove(node)
  if node[self._np] then
    if node[self._pp] then
      node[self._np][self._pp] = node[self._pp]
      node[self._pp][self._np] = node[self._np]
    else
      node[self._np][self._pp] = nil
      self._first = node[self._np]
    end
  elseif node[self._pp] then
    node[self._pp][self._np] = nil
    self._last = node[self._pp]
  else
    self._first = nil
    self._last = nil
  end

  node[self._np] = nil
  node[self._pp] = nil
  self._length = self._length - 1
end

function LinkedList:clear(complete)
  if complete then
    for v in self:iterate() do
      v[self._np] = nil
      v[self._pp] = nil
    end
  end
  
  self._first = nil
  self._last = nil
  self._length = 0
end

local function iterate(self, current)
  if current then
    current = current[self._np]
  else
    current = self._first
  end
  
  return current
end

-- delete-safe iteration using extra property
local function safeIterate(self, current)
  if current then
    local newCur = current[self._inp]
    current[self._inp] = nil
    current = newCur
  else
    current = self._first
  end
  
  if current then
    current[self._inp] = current[self._np]
  end

  return current
end

local function reverseIterate(self, current)
  if current then
    current = current[self._pp]
  else
    current = self._last
  end
  
  return current
end

local function reverseSafeIterate(self, current)
  if current then
    local newCur = current[self._ipp]
    current[self._ipp] = nil
    current = newCur
  else
    current = self._last
  end

  if current then
    current[self._ipp] = current[self._pp]
  end

  return current
end


function LinkedList:iterate(reverse)
  return (reverse and reverseIterate or iterate), self, nil
end

function LinkedList:safeIterate(reverse)
  return (reverse and reverseSafeIterate or safeIterate), self, nil
end
