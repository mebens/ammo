This a quick example showing how to create a really simple game using Ammo.

## Setup

Create a new folder and name it whatever you want. Now download Ammo with these terminal commands:

``` bash
$ cd your-game-dir-here
$ git clone git://github.com/BlackBulletIV/ammo.git
$ cd ammo
$ git submodule update --init
```

## `main.lua`

`main.lua` will have this code:

``` lua
require("ammo")
require("GameWorld")
require("Player")

function love.load()
  ammo.world = GameWorld:new()
end
```

We don't have to do anything other than instantiate and set the world. `GameWorld` is a subclass of `[[World]]`, and `Player` is a subclass of `[[Entity]]`, both of which we'll get to in a moment.

Ammo automatically sets `love.update` and `love.draw` to `ammo.update` and `ammo.draw`, so we don't have to worry about those.

## The World

Now we need to create our subclass of `[[World]]`. Since this is a very simple example, we only need one, but in more complex games you'll probably need many types of worlds.

``` lua
GameWorld = class("GameWorld", World)

function GameWorld:initialize()
  World.initialize(self)
  self:add(Player:new(love.graphics.width / 2, love.graphics.height / 2))
end
```

All this world does is add a new instance of the Player entity, positioning it at the centre of the screen.

## The Player

This is where things get a bit more interesting:

``` lua
Player = class("Player", Entity)
Player.static.speed = 500

function Player:initialize(x, y)
  Entity.initialize(self, x, y)
  self.width = 50
  self.height = 50
  self.color = { 240, 0, 0 }
end

function Player:update(dt)
  local xAxis = 0
  local yAxis = 0
  if love.keyboard.isDown("left") then xAxis = xAxis - 1 end
  if love.keyboard.isDown("right") then xAxis = xAxis + 1 end
  if love.keyboard.isDown("up") then yAxis = yAxis - 1 end
  if love.keyboard.isDown("down") then yAxis = yAxis + 1 end
  
  self.x = self.x + Player.speed * xAxis * dt
  self.y = self.y + Player.speed * yAxis * dt
  self.x = math.clamp(self.x, self.width / 2, love.graphics.width - self.width / 2)
  self.y = math.clamp(self.y, self.height / 2, love.graphics.height - self.height / 2)
end

function Player:draw()
  love.graphics.pushColor(self.color)
  love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
  love.graphics.popColor()
end
```

### `initialize`

`initialize` sets some variables for the width, height, and color of the player. It also lets `Entity:initialize` take care of the X and Y coordinates.

### `update`

`update` handles the movement of the player. It works out which direction the player should move in based on the keys being held down by the user. It also makes sure that the player stays within the bounds of the window. Note that, since I've decided to make `Player` use centre-based coordinates we have add/subtract half the width/height where needed.

### `draw`

`draw` draws a rectangle based on the information inside the player object. It also makes use of the `love.graphics.pushColor` and `popColor` helpers provided by Ammo.

## Conclusion

With those files in place, you should now have a red square which you can move around. I've only scratched the surface of what you can do within the framework, but hopefully this will give you a better idea of how the pieces fit together.
