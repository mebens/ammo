SoundPool = class("SoundPool", Sound)

local function fillPool(count, proto, pool, using)
  diff = count - (pool.length + using.length)

  if diff > 0 then
    for i = 1, diff do
      pool:push({ proto:clone() })
    end
  end
end

local function reclaimSources(pool, using)
  for s in using:safeIterate() do
    if not s[1]:isPlaying() then
      using:remove(s)
      pool:push(s)
    end
  end
end

function SoundPool:initialize(data, volume, stream)
  Sound.initialize(self, data, volume, stream)
  self.active = true

  if self._multi then
    self._pools = {}
    self._using = {}

    for i, v in ipairs(data) do
      self._pools[i] = LinkedList:new()
      self._using[i] = LinkedList:new()
    end
  else
    self._pool = LinkedList:new()
    self._using = LinkedList:new()
  end
end

function SoundPool:fill(count)
  local diff, proto

  if self._multi then
    for i, v in ipairs(self._protos) do
      fillPool(count, v, self._pools[i], self._using[i])
    end
  else
    fillPool(count, self._proto, self._pool, self._using)
  end
end

local rand = math.random

function SoundPool:play()
  local proto, pool, using, src

  if self._multi then
    local index = rand(1, #self._protos)
    pool = self._pools[index]
    proto = self._protos[index]
    using = self._using[index]
  else
    pool = self._pool
    proto = self._proto
    using = self._using
  end

  if pool.length > 0 then
    src = pool:pop()
  else
    src = { proto:clone() }
  end
  
  using:push(src)
  src = src[1]
  src:seek(0)
  src:play()
  return src
end

function SoundPool:reclaim()
  if self._multi then
    for i, v in ipairs(self._pools) do
      reclaimSources(v, self._using[i])
    end
  else
    reclaimSources(self._pool, self._using)
  end
end

SoundPool.update = SoundPool.reclaim

function SoundPool:count(index)
  if index then
    return self._pools[index].length + self._using[index].length
  elseif self._multi then
    local count = 0

    for i, v in ipairs(self._pools) do
      count = count + v.length + self._using[i].length
    end

    return count
  else
    return self._pool.length + self._using.length
  end
end
