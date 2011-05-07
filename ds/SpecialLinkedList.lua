--[[
  Just like the LinkedList class, except that it uses
  special custom nodes which the user provides, and
  uses given property names to access the next and
  previous elements in the list. When adding things
  to the list, you must use an already constructed
  node, rather than a value. You'll also have to be
  careful, because this linked list doesn't keep track
  of which lists nodes belong to.
  
  This functionality is used for the lists of entities
  stored inside of the World object, as there are a
  number of lists which entities are a part of.
  
  The advantage of LinkedList of SpecialLinkedList is
  that LinkedList does not have to contstantly look
  up the name of the property it should use when
  dealing with nodes. This, at least in theory, wiil
  mean that LinkedList is a bit faster.
--]]
SpecialLinkedList = class('SpecialLinkedList')

local mt = {}

function mt:__index(key)
  return rawget(self, '_' .. key) or SpecialLinkedList.__classDict[key]
end

--[[
  Initializes the linked list. You can pass arguments
  to this function and they will be added to the list
  via push().
  
  -- Parameters --
  nextProp:string
  See the np property.
  
  prevProp:string
  See the pp property.
  
  ...:mixed
  Values you want added to the list on initialization.
--]]
function SpecialLinkedList:initialize(nextProp, prevProp, ...)
  -- attributes
  self._first = nil
  self._last = nil
  self._np = nextProp or '_next'
  self._pp = prevProp or '_prev'
  self._length = 0
  
  -- enabled getter functionality
  local old = getmetatable(self)
  old.__index = mt.__index
  
  -- push elements, if any
  self:push(...)
end

--[[
  Appends the given nodes onto the back of the list.
  
  -- Parameters --
  ...:mixed
  One or more nodes to be appended.
--]]
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
  
  self._length = self._length + select('#', ...)
end

--[[
  Does the same thing as push, but it prepends the nodes
  to the front of the list.
  
  -- Parameters --
  ...:mixed
  One or more nodes to be preprended.
--]]
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
  
  self._length = self._length + select('#', ...)
end

--[[
  Inserts a value in the list after the specified node. The
  node given must belong to this list.
  
  -- Parameters --
  node:mixed
  The value you want added.
  
  after:mixed
  The node you want the node specified added after.
  
  -- Returns --
  mixed
  The node added.
--]]
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

--[[
  Removes the last element from the list.
  
  -- Returns --
  mixed
  The node removed.
--]]
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

--[[
  Removes the first element from the list.
  
  -- Returns --
  mixed
  The node removed.
--]]
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

--[[
  Removes one or more element(s) from the list.
  
  -- Parameters --
  ...:mixed
  One or more element(s) you want removed.
--]]
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

--[[
  Clears all elements out of the list.
  
  -- Parameters --
  complete:boolean
  If true, this will cause this function to loop through all
  the elements, unlinking them. This will only be useful if 
  elements referencing each other will be a problem.
--]]
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

--[[
  Moves the node forward one place.
  
  -- Parameters --
  node:mixed
  The node you want moved.
  
  -- Returns --
  boolean
  Whether or not the node was moved.
--]]
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

--[[
  Moves the node backward one place.
  
  -- Parameters --
  node:mixed
  The node you want moved.
  
  -- Returns --
  boolean
  Whether or not the node was moved.
--]]
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

--[[
  Brings the node to the front of the list.
  
  -- Parameters --
  node:mixed
  The node you want brought to the front.
  
  -- Returns --
  boolean
  Whether or not the node was moved.
--]]
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

--[[
  Sends the node to the back of the list.
  
  -- Parameters --
  node:mixed
  The node you want sent to the back.
  
  -- Returns --
  boolean
  Whether or not the node was moved.
--]]
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

--[[
  Gets all the elements in the list and puts them in a table.
  It's not suggested to call this every frame or something,
  as the function does loop over every element.
  
  -- Returns --
  table
  All the elements of the list in a table.
--]]
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

--[[
  Returns an iterator for the generic for loop. The iterator
  returns the current node on each iteration.
  
  -- Parameters --
  reverse:boolean
  If true, the iterator will move in reverse order.
  
  -- Returns --
  function
  The iterator.
  
  -- Example --
  You could use it like this:
  
  for n in list:getIterator() do
    print("node: " .. n)
  end
--]]
function SpecialLinkedList:getIterator(reverse)
  return (reverse and reverseIterate or iterate), self, nil
end
